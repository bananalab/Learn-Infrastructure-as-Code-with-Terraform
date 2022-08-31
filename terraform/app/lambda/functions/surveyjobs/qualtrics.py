#!/usr/bin/env python
"""
Export variable:

    export X_API_TOKEN=xxxx

Sync to Dynamo like this:

./qualtrics.py sync-db

"""
import base64
import zipfile
import io
import os
import sys
import json
import urllib.parse
import time
import dateutil.parser


import boto3
import botocore
import requests
import pandas as pd
import click

from hashlib import md5

#SETUP LOGGING
import logging
from pythonjsonlogger import jsonlogger

LOG = logging.getLogger()
LOG.setLevel(logging.DEBUG)
logHandler = logging.StreamHandler()
formatter = jsonlogger.JsonFormatter()
logHandler.setFormatter(formatter)
LOG.addHandler(logHandler)

#S3 BUCKET
REGION = "us-east-1"
DYNAMODB = boto3.resource('dynamodb')
TABLE = None

def setup_environment():
        ### Qualtrics ###
    try:
        api_token = os.environ['X_API_TOKEN']
    except KeyError:
        LOG.error("ERROR!: set environment variable X_API_TOKEN")
        sys.exit(2)
    LOG.info(f"Using 'X_API_TOKEN': {api_token}")

    ### DynamoDB
    try:
        AGENCIES_TABLE_ID = os.environ['AGENCIES_TABLE_ID']
        table = DYNAMODB.Table(AGENCIES_TABLE_ID)
    except KeyError:
        LOG.error("ERROR!: set environment variable AGENCIES_TABLE_ID [comes from Jet Steps: i.e. policeDepartments-6a2557316621d95d]")
        sys.exit(2)

    LOG.info(f"Using 'AGENCIES_TABLE_ID': {AGENCIES_TABLE_ID}")
    LOG.info(f"Using DYNAMODB TABLE: {TABLE}")
    return api_token, table


### KMS Utils###

def encrypt(secret, extra=None):
    if secret == "":
        LOG.info('Encrypting empty string', extra=extra)
        return ""
    client = boto3.client('kms')
    key_alias = os.environ.get('KMS_KEY')
    ciphertext = client.encrypt(
        KeyId=key_alias,
        Plaintext=secret,
    )
    LOG.info(f'Encrypted value: {ciphertext}')
    return base64.b64encode(ciphertext['CiphertextBlob'])


def decrypt(secret, extra=None):
    client = boto3.client('kms')
    LOG.info(f'Decrypting: {secret}', extra)
    plaintext = client.decrypt(
        CiphertextBlob=base64.b64decode(secret)
    )
    return plaintext['Plaintext']


### SQS Utils###

def sqs_queue_resource(queue_name):
    """Returns an SQS queue resource connection

    Usage example:
    In [2]: queue = sqs_queue_resource("dev-job-24910")
    In [4]: queue.attributes
    Out[4]: 
    {'ApproximateNumberOfMessages': '0',
     'ApproximateNumberOfMessagesDelayed': '0',
     'ApproximateNumberOfMessagesNotVisible': '0',
     'CreatedTimestamp': '1476240132',
     'DelaySeconds': '0',
     'LastModifiedTimestamp': '1476240132',
     'MaximumMessageSize': '262144',
     'MessageRetentionPeriod': '345600',
     'QueueArn': 'arn:aws:sqs:us-west-2:414930948375:dev-job-24910',
     'ReceiveMessageWaitTimeSeconds': '0',
     'VisibilityTimeout': '120'}

    """

    sqs_resource = boto3.resource('sqs', region_name=REGION)
    log_sqs_resource_msg = "Creating SQS resource conn with qname: [%s] in region: [%s]" %\
     (queue_name, REGION)
    LOG.info(log_sqs_resource_msg)
    queue = sqs_resource.get_queue_by_name(QueueName=queue_name)
    return queue

def sqs_connection():
    """Creates an SQS Connection which defaults to global var REGION"""

    sqs_client = boto3.client("sqs", region_name=REGION)
    log_sqs_client_msg = "Creating SQS connection in Region: [%s]" % REGION
    LOG.info(log_sqs_client_msg)
    return sqs_client

def sqs_approximate_count(queue_name):
    """Return an approximate count of messages left in queue"""

    queue = sqs_queue_resource(queue_name)
    attr = queue.attributes
    num_message = int(attr['ApproximateNumberOfMessages']) 
    num_message_not_visible = int(attr['ApproximateNumberOfMessagesNotVisible'])
    queue_value = sum([num_message, num_message_not_visible])
    sum_msg = """'ApproximateNumberOfMessages' and 'ApproximateNumberOfMessagesNotVisible' = *** [%s] *** for QUEUE NAME: [%s]""" %\
         (queue_value, queue_name)
    LOG.info(sum_msg)
    return queue_value

def delete_sqs_msg(queue_name, receipt_handle):

    sqs_client = sqs_connection()
    try:
        queue_url = sqs_client.get_queue_url(QueueName=queue_name)["QueueUrl"]
        delete_log_msg = "Deleting msg with ReceiptHandle %s" % receipt_handle
        LOG.info(delete_log_msg)
        response = sqs_client.delete_message(QueueUrl=queue_url, ReceiptHandle=receipt_handle)
    except botocore.exceptions.ClientError as error:
        exception_msg = "FAILURE TO DELETE SQS MSG: Queue Name [%s] with error: [%s]" %\
            (queue_name, error)
        LOG.exception(exception_msg)
        return None

    delete_log_msg_resp = "Response from delete from queue: %s" % response
    LOG.info(delete_log_msg_resp)
    return response


### S3 ###
def s3_resource():
    """Create S3 Resource"""

    resource = boto3.resource('s3', region_name=REGION)
    LOG.info("s3 RESOURCE connection initiated")
    return resource

def write_s3(source_file, file_to_write, bucket):
    """Write S3 Bucket"""

    # Boto 3
    s3 = s3_resource()
    path = f'{source_file}'
    res = s3.Object(bucket, file_to_write).\
            put(Body=open(path, 'rb'))
    LOG.info(f"result of write {file_to_write} | {bucket} with:\n {res}")
    s3_payload = (bucket, file_to_write)
    return s3_payload

def df_read_csv(file_to_read, bucket):
    """Uses pandas to read s3 csv and return DataFrame

    Ref:
    https://stackoverflow.com/questions/37703634/\
    how-to-import-a-text-file-on-aws-s3-into-pandas\
    -without-writing-to-disk

    output looks like:

    In [12]: df.columns
    Out[12]:
    Index(['StartDate', 'EndDate', 'Status', 'IPAddress', 'Progress',
       'Duration (in seconds)', 'Finished', 'RecordedDate', 'ResponseId',
       'RecipientLastName', 'RecipientFirstName', 'RecipientEmail',
       'ExternalReference', 'LocationLatitude', 'LocationLongitude',
       'DistributionChannel', 'UserLanguage', 'Q1', 'Q2',
       'Q_RecipientPhoneNumber'],
      dtype='object')

    """

    s3 = boto3.client('s3')
    obj = s3.get_object(Bucket=bucket, Key=file_to_read)
    LOG.info(f"reading s3:{bucket}/{file_to_read}")
    df = pd.read_csv(io.BytesIO(obj['Body'].read()))
    return df

def list_qualtrics_bucket_content(bucket):
    """Lists content of qualtrics bucket

    Ref:
    https://stackoverflow.com/questions/30249069/\
        listing-contents-of-a-bucket-with-boto3
    """

    s3 = boto3.resource('s3')
    my_bucket = s3.Bucket(bucket)
    for found_key in my_bucket.objects.all():
        print(f"Bucket: {bucket} | key: {found_key}")

def size_of_zip(file_handle):
    """finds zip size"""

    size = sum([zinfo.file_size for zinfo in  file_handle.filelist])
    return size

def download_csv_survey(survey_id="SV_1G2GmpaXrcPAenr",
    api_token=None, data_center="co1", file_format="csv", temp_location="/tmp"):
    """Download Survey"""

    extra_logging = {"survey_id": survey_id, "temp_location": temp_location}
    # Setting static parameters
    requestCheckProgress = 0.0
    progressStatus = "inProgress"
    baseUrl = "https://{0}.qualtrics.com/API/v3/surveys/{1}/export-responses/".format(data_center, survey_id)
    headers = {
        "content-type": "application/json",
        "x-api-token": api_token,
        }

    # Step 1: Creating Data Export
    downloadRequestUrl = baseUrl
    downloadRequestPayload = '{"format":"' + file_format + '"}'
    downloadRequestResponse = requests.request("POST",
        downloadRequestUrl, data=downloadRequestPayload, headers=headers)
    progressId = downloadRequestResponse.json()["result"]["progressId"]
    LOG.info(downloadRequestResponse.text, extra=extra_logging)

    # Step 2: Checking on Data Export Progress and waiting until export is ready
    while progressStatus != "complete" and progressStatus != "failed":
        LOG.info(f"progressStatus {progressStatus}", extra=extra_logging)
        requestCheckUrl = baseUrl + progressId
        requestCheckResponse = requests.request("GET", requestCheckUrl, headers=headers)
        requestCheckProgress = requestCheckResponse.json()["result"]["percentComplete"]
        LOG.info(f"Download is {str(requestCheckProgress)} complete", extra=extra_logging)
        progressStatus = requestCheckResponse.json()["result"]["status"]

    #step 2.1: Check for error
    if progressStatus is "failed":
        LOG.error("export failed", extra=extra_logging)
        raise Exception("export failed")

    fileId = requestCheckResponse.json()["result"]["fileId"]

    # Step 3: Downloading file
    requestDownloadUrl = baseUrl + fileId + '/file'
    requestDownload = requests.request("GET", requestDownloadUrl, headers=headers, stream=True)

    # Step 4: Unzipping the file
    zip_temp = io.BytesIO(requestDownload.content)
    zp = zipfile.ZipFile(zip_temp)
    size = size_of_zip(zp) #returns size and logs it
    filename = zp.namelist()[0]
    LOG.info(f"Zip Size is: {size} with filename: {filename}", extra=extra_logging)
    output_filename = f"{temp_location}/{survey_id}.csv"
    LOG.info(f"Writing ZIP CONTENTS to output_filename: {output_filename}", extra=extra_logging)
    with open(output_filename, "wb") as output_file:
        LOG.info(f"Reading zipfile with name: {filename}", extra=extra_logging)
        output_file.write(zp.read(filename))

    LOG.info(f"Zip Extraction Complete.  Returning filename: {output_filename}", extra=extra_logging)
    return output_filename

def collect_survey_endpoint(url="https://co1.qualtrics.com/API/v3/surveys/",
                        survey_id="SV_4JFLLqWZwHJGi3z",extra=None, api_token=None):

    """Grabs the information about a single survey
    
    Example url created
    https://co1.qualtrics.com/API/v3/surveys/SV_4JFLLqWZwHJGi3z
    """
    
    endpoint = urllib.parse.urljoin(url,survey_id)
    LOG.info(f"Creating endpoint: {endpoint} from url: {url} and survey_id: {survey_id}", extra=extra)
    headers = {
        "content-type": "application/json",
        "x-api-token": api_token,
        }
    result = requests.get(endpoint, headers=headers)
    json_response = result.json()
    LOG.info(f"JSON result: {json_response} of endpoint {endpoint}", extra=extra)
    return json_response

##Pandas Mapping##############################
##############################################
def get_question_metadata(df, extra):
    """Accepts original DataFrame and grabs Qualtrics MetaData
    
    'Q0': '{"ImportId":"QID24"}',
    'Q1': '{"ImportId":"QID135400005_TEXT"}',
    """
    
    metadata_recs = {}
    for key, value in df.iloc[1].items():
        metadata_recs[key]=value
    LOG.info(f"Metadata recs: {metadata_recs}", extra=extra)
    return metadata_recs

def make_sort(question, responseid, extra=None):
    """Makes Sort"""
    
    sort_value = f"RID-{question}-{responseid}"
    LOG.info(f"Creating sort_value: {sort_value}", extra=extra)
    return sort_value



def sentiment_mapper(sentiment):
    """Maps a sentiment to a numerical value"""

    sentiment_map = {
        "NEGATIVE": '1',
        "MIXED":    '0',
        "NEUTRAL":  '2',
        "POSITIVE": '3',
    }
    result = sentiment_map[sentiment]
    LOG.info(f"Sentiment found {sentiment} with result {result}")
    return result

def create_sentiment(row, extra=None):
    """Uses AWS Comprehend to Create Sentiment
    
    Return Categorical Sentiment:  Positive, Neutral, Negative:
    
    Example payload from comprehend:
    {'Sentiment': 'NEUTRAL',
    'SentimentScore': {'Positive': 0.05472605302929878,
     'Negative': 0.011656931601464748,
     'Neutral': 0.9297710061073303,
     'Mixed': 0.003845960134640336},
    
    """

    LOG.info(f"CREATE SENTIMENT with raw value: {row}", extra=extra)
    comprehend = boto3.client(service_name='comprehend')
    payload = comprehend.detect_sentiment(Text=row, LanguageCode='en')
    LOG.info(f"Found Sentiment: {payload}", extra=extra)    
    sentiment_category = payload['Sentiment']
    LOG.info(f"Sentiment Category: {sentiment_category}", extra=extra)
    sentiment_score = payload['SentimentScore']
    LOG.info(f"Sentiment Score: {sentiment_score}", extra=extra)
    map_sentiment_result = sentiment_mapper(sentiment=sentiment_category)
    LOG.info(f"Created Sentiment Score: {map_sentiment_result}")
    return map_sentiment_result

def make_record(iloc, extra=None, questions_choices=None):
    """Makes DynamoDB Record From DataFrame
    
    response = {
    ## More information about these fields
    #https://docs.google.com/document/d/1A4UQvA8uNC6boQ3OjO-G0v9EdVrypKUS4KpCqmulPTM/edit
    
    """

    LOG.info(f"make_record: Making Record for dyanamodb", extra=extra)
    recs = []
    partition = iloc.get("Partition")
    responseid = iloc.get("_recordId")
    question_index = [col for col in iloc.keys() if (col.startswith("QID") or col == 'Text')]
    for question in question_index:       
        question_value = iloc[question]
        if not question_value:
            LOG.info(f"Empty Question: {question}", extra=extra) 
            continue
        else:
            LOG.info(f"Processing Question:{question}", extra=extra)
        new_rec = {}

        if question == "Text":
            LOG.info(f"Found Text question: {question} with value {question_value}", extra=extra)
            # Parse response, it contains the question id
            # response format for these: <USER ENTERED TEXT>/<QUESTION ID>/ChoiceTextEntryValue}

            text, question, response_type = question_value.split('/')

            if text and question.startswith('QID'):
                #Since there is Text, we can also create sentiment
                new_rec["Text"] = text
                new_rec["Sentiment"] = create_sentiment(row=new_rec["Text"],extra=extra) 
                # We want to match the question id of the question in it's own column
                # so we don't make duplicate rows
                question = f"{question}_TEXT"
            else:
                LOG.warning(f"Unable to process response: {question_value}", extra=extra)
                continue
        elif question.endswith("_TEXT"):
            LOG.info(f"Found open response question {question} with value {question_value}", extra=extra)
            new_rec["OpenResponse"] = question_value
        else:
            LOG.info(f"Found CHOICE question: {question} with value {question_value}", extra=extra)
            new_rec["Choice"] = question_value

        try:
            new_rec["Sort"] = make_sort(question, responseid, extra=extra) 
            new_rec["Partition"] = partition
            new_rec["LSI"] = question
            new_rec["Origin"] = iloc.get("Origin")
            new_rec["Race"] = iloc.get("Race")
            new_rec["Age"] = iloc.get("Age")
            new_rec["Gender"] = iloc.get("Gender")
            
           
            #handle empty latitude
            latitude = iloc.get('Latitude') or 0.0
            new_rec["Latitude"] = latitude
            new_rec["LatitudeOffset"] = f"{float(latitude):019.15F}" 
            
            #handle empty longitude
            longitude = iloc.get('Longitude') or 0.0
            new_rec["Longitude"] = longitude
            new_rec["LongitudeOffset"] = f"{(float(longitude) + 200):019.15F}"
            
            new_rec["Date"] = str(time.mktime(dateutil.parser.parse(iloc.get("Date")).timetuple()))
            new_rec["IncidentId"] = iloc.get("IncidentId")
            new_rec["rojopolisEncounterScore"] = iloc.get("rojopolisEncounterScore")
            new_rec["rojopolisGeneralScore"] = iloc.get("rojopolisGeneralScore")
            
            #handle empty phone set to: 00000000000
            phone_number = iloc.get("PhoneNumber") or "00000000000"
            new_rec["PhoneNumber"] = encrypt(phone_number)
        
        except Exception as error:
            LOG.exception(f"Problem making record", extra=extra)
            raise error
        if question in questions_choices:
            new_rec["QuestionChoicesId"] = questions_choices[question]
        LOG.info(f"new_rec **BEFORE** None filter: {new_rec}", extra=extra)
        new_rec = {x:y for x,y in new_rec.items() if y != ""}
        LOG.info(f"new_rec **AFTER** None filter: {new_rec}", extra=extra)
        recs.append(new_rec)
    LOG.info(f"Created Records: {recs}", extra=extra)
    return recs

def get_question_columns(df, extra):
    """takes a DataFrame and returns Question Key/Value Pairs """

    cols = [col for col in list(df.columns) if (col.startswith("QID") or col == 'Text')]
    LOG.info(f"Found Question Columns: {cols}", extra=extra)
    return cols

def fill_empty_values(df=None, fill_value="", extra=None):
    """Fills empty values with fill value, defaults to empty string"""

    LOG.info(f"Filling DataFrame Empty Values with fill value: {fill_value}", extra=extra)
    df_filled = df.fillna(fill_value)
    return df_filled
      
def rename_df_colnames_cleanup(df,extra):
    """Rename the columns, drop first two rows and clean"""

    #rename columns
    import ast
    vals = df.iloc[1].tolist()
    columns = [ast.literal_eval(x)['ImportId'] for x in vals]
    df.columns = columns
    LOG.info(f"Set Columns via AST Rename: {columns}")
    
    #go back to renaming
    new_columns = {}
    recs = get_question_metadata(df, extra)
    LOG.info(f"rename_df_colnames_cleanup: METADATA {recs}", extra=extra)
    cols = get_question_columns(df,extra)
    new_recs = dict((k, recs[k]) for k in cols)
    LOG.info(f"rename_df_colnames_cleanup: NEW_COLUMNS: {new_recs}", extra=extra)
    for key,value in new_recs.items():
        values = eval(value)
        LOG.info(f"rename_df_colnames_cleanup: VALUES: {values}", extra=extra)
        new_columns[key]= list(values.values())[0]
    LOG.info(f"Created new DataFrame Column Names: NEW_COLUMNS {new_columns}", extra=extra)
    df = df.rename(columns=new_columns)
    #drop row
    df = df.iloc[1:]
    LOG.info(f"Dropped first row: {df.head(2)}", extra=extra)
    df = fill_empty_values(df=df, extra=extra)
    return df

def populate_dynamodb(rec, extra=None):
    """Creates a DynamoDB Record"""

    LOG.info(f"Populating DynamoDB with rec: {rec}", extra=extra)
    try:
        res = TABLE.put_item(Item=rec)
    except Exception: # pylint:disable=broad-except
        LOG.exception(f"FATAL--ERROR--WRITING--TO--DYNAMO for rec: {rec}", extra=extra)
        return None
    LOG.info(f"SUCCESS**WRITE**RECORD**DYNAMO for rec {rec} with response: {res}", extra=extra)

def pd_table_populate(df=None, extra=None, survey_id=None, api_token=None, agency_id=None):
    """Populate DynamoDB with contents of survey dataframe"""

    #collect survey metadata
    response = collect_survey_endpoint(survey_id=survey_id, 
            extra=extra, api_token=api_token) 
    questions, choices = process_questions_from_survey(aid=agency_id, 
                                        survey_data=response['result'], extra=extra)
    LOG.info(f"Creating questions {questions} and choices {choices}", extra=extra)
    
    #Process Questions
    for question in questions:
        LOG.info(f"Processing question: {question}", extra=extra)
        populate_dynamodb(question, extra=extra)    
    
    #Process Choices
    for choice in choices:
        LOG.info(f"Processing choice: {choice}", extra=extra)
        populate_dynamodb(choice, extra=extra)   

    #Create Question Choices
    questions_choices = {x['Sort']: x['QuestionChoicesId'] for x in questions if 'QuestionChoicesId' in x}
    LOG.info(f"Create Question Choices: {questions_choices}", extra=extra)

    #Rename columns and process records
    df = rename_df_colnames_cleanup(df, extra)
    LOG.info(f"Created DataFrame: {df.iloc[1]}", extra=extra)
    rows,_ = df.shape
    LOG.info(f"Found number of rows: {rows}", extra=extra)
    for index in range(1,rows):
        LOG.info(f"Processing DataFrame Row {index}", extra=extra)
        recs = make_record(df.iloc[index], extra=extra, questions_choices=questions_choices)
        for rec in recs:
            LOG.info(f"Processing a rec: {rec}", extra=extra)
            populate_dynamodb(rec, extra=extra)
    LOG.info(f"FINISHED: Processing DataFrame Rows", extra=extra)
    return df


def process_questions_from_survey(aid, survey_data, extra=None):
    ''' Take suvey data and determine quesion choices and questions to make
        returns two lists of dicts, one representing questions and one
        representing question choices.

        Params:
            aid: string id of the agency
            survey_data: 'result' section from qualtrics survey endpoint
    '''
    questions_items = []
    choices_items = []
    if survey_data:
        LOG.info(f"survey_data {survey_data}, aid {aid}", extra=extra)
        for question_key, question_data in survey_data['questions'].items():
            question_item = {'Partition': aid,
                             'Sort': question_key,
                             'Text': question_data['questionText']}

            if 'choices' in question_data:
                # The choices should be ordered by the 'recode' field
                choices_texts = [y['choiceText'] for y in sorted(question_data['choices'].values(), key=lambda x:x['recode'])]
                h = md5()
                h.update(str(choices_texts).encode())
                qcid = f"QCID-{h.hexdigest()}"
                choices_items.append({'Partition': aid,
                                      'Sort': qcid,
                                      'Choices':str(choices_texts)})

                question_item['QuestionChoicesId'] = qcid

            questions_items.append(question_item)

    return questions_items, choices_items


def entrypoint(event, context):
    '''
    Lambda entrypoint
    '''

    LOG.info(f"SURVEYJOB LAMBDA, event {event}, context {context}", extra=os.environ)
    receipt_handle  = event['Records'][0]['receiptHandle'] #sqs message
    #'eventSourceARN': 'arn:aws:sqs:us-east-1:698112575222:etl-queue-etl-resources'
    event_source_arn = event['Records'][0]['eventSourceARN']
    for record in event['Records']:
        body = json.loads(record['body'])
        survey_id = body['SurveyId']
        agency_id = body['AgencyId']
        api_token = os.environ.get('X_API_TOKEN')
        table_id = os.environ.get('AGENCIES_TABLE_ID')
        global TABLE # pylint:disable=W0603
        TABLE = DYNAMODB.Table(table_id)# pylint:disable=W0621
        bucket = os.environ.get('S3_BUCKET')
        extra_logging = {"body": body, "survey_id": survey_id, "lambda role": "SURVEYJOB",
         "agency_id":agency_id, api_token: "api_token", "bucket": bucket, "table": {TABLE}}
        LOG.info(f"SURVEYJOB LAMBDA, splitting sqs arn with value: {event_source_arn}",extra=extra_logging)
        qname = event_source_arn.split(":")[-1]
        extra_logging["queue"] = qname
        LOG.info(f"Calling click run function:  Will download qualtrics data and write to s3", extra=extra_logging)
        written_bucket, downloaded_csv_file = cli.main(
            args=[
                'run',
                '--surveyid', survey_id,
                '--apitoken', api_token,
                '--bucket', bucket,
                '--queue', qname
            ],
            standalone_mode=False
        )
        LOG.info(f"this is downloaded_csv_file path: {downloaded_csv_file} from bucket: {written_bucket}",extra=extra_logging)
        extra_logging["csvfile"] = downloaded_csv_file
        extra_logging["written_bucket"] = written_bucket
        LOG.info(f"Running sync-db click function:  will read from s3 and map csv data to dynamodb",extra=extra_logging)
        cli.main(
            args=[
                'sync-db',
                '--surveyid', survey_id,
                '--apitoken', api_token,
                '--bucket', written_bucket,
                '--agencyid', agency_id,
                '--csvfile', downloaded_csv_file,
                  '--queue', qname
            ],
            standalone_mode=False
        )
        LOG.info(f"Attemping Deleting SQS receiptHandle {receipt_handle} with queue_name {qname}", extra=extra_logging)
        res = delete_sqs_msg(queue_name=qname, receipt_handle=receipt_handle)
        LOG.info(f"Deleted SQS receipt_handle {receipt_handle} with res {res}", extra=extra_logging)

@click.group()
def cli():
    pass

@click.option("--qurl",
    default="etl-queue-etl-resources",
    help="Finds out number of messages in a AWS queue")
@cli.command()
def qcount(qurl):
    """Util for Queue count"""

    LOG.info(f"Using queue name {qurl}")
    click.echo(sqs_approximate_count(queue_name=qurl))

@cli.command()
@click.option("--surveyid", envvar="SURVEY_TABLE",
    default="SV_1G2GmpaXrcPAenr", help="qualtrics survey id")
@click.option("--apitoken", envvar="X_API_TOKEN", help="apitoken")
@click.option("--bucket", envvar="SURVEY_BUCKET", help="S3 bucket to write survey csv")
@click.option("--queue", default=None)
def run(surveyid, apitoken, bucket, queue):
    """Run export via cli and write to s3"""

    extra_logging = {"surveyid":surveyid, "apitoken":apitoken, "bucket":bucket, "queue":queue}
    LOG.info(f"Running Click run with surveyid", extra=extra_logging)
    downloaded_csv_file = download_csv_survey(api_token=apitoken, survey_id=surveyid)
    file_name = os.path.split(downloaded_csv_file)[-1]
    LOG.info(f"Found filename {file_name}", extra=extra_logging)
    s3_name_to_create = f"{surveyid}-{file_name}"
    LOG.info(f"Writing qualtrics download with name: {s3_name_to_create} to S3", extra=extra_logging)
    s3_file_handle = write_s3(source_file=downloaded_csv_file,
        file_to_write=s3_name_to_create, bucket=bucket)
    LOG.info(f"Running export with downloaded_csv_file {downloaded_csv_file}", extra=extra_logging)
    LOG.info(f"Boto S3 file handle:  {s3_file_handle}", extra=extra_logging)
    return s3_file_handle

@cli.command()
@click.option("--csvfile", envvar="CSV_FILE",
    help="s3 based csv file")
@click.option("--bucket", envvar="SURVEY_BUCKET",
    help="s3 bucket")
@click.option("--agencyid",
    help="Agency ID")
@click.option("--queue", default=None)
@click.option("--surveyid", envvar="SURVEY_TABLE",
    default="SV_1G2GmpaXrcPAenr", help="qualtrics survey id")
@click.option("--apitoken", envvar="X_API_TOKEN", help="apitoken")
def sync_db(csvfile, bucket, agencyid, queue, surveyid, apitoken):
    """Sync CSV to DynamoDB
    
    
    To test locally:

    python qualtrics.py sync-db --bucket rojopolis-survey-us-east-1-698112575222 \
            --csvfile "SV_cGXWxvADgIihxrf-Example Qualtrics Output.csv"

    """
    saved_args = locals()
    LOG.info(f'locals in sync_db: {saved_args}')
    extra_logging = {
        "csvfile": csvfile,
        "bucket": bucket,
        "agencyid": agencyid,
        "queue": queue,
        "function_name" :"sync_db",
        "locals": saved_args
    }
    LOG.info(f"Running Click syncdb with csvfile", extra=extra_logging)
    df = df_read_csv(
        file_to_read=csvfile,
        bucket=bucket
    )
    LOG.info(f"Contents of initial dataframe: {df.to_dict()}", extra=extra_logging)
    #LOG.info(f"Found Survey Metadata: {}")
    LOG.info(f"Found DataFrame Columns: {df.columns}", extra=extra_logging);df.head()
    LOG.info(f"START SYNCDB:", extra=extra_logging)
    pd_table_populate(df,extra=extra_logging, survey_id=surveyid, 
                    api_token=apitoken, agency_id=agencyid)
    LOG.info(f"FINISH SYNCDB: ", extra=extra_logging)

if __name__ == "__main__":
    API_TOKEN, TABLE = setup_environment()
    cli()
