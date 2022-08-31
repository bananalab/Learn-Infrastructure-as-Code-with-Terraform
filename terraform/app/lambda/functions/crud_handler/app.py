'''
CRUD Handler
'''
import os
import pprint
import logging
import json
import decimal
from ast import literal_eval
from statistics import mean
from functools import reduce
from itertools import groupby
from operator import itemgetter
from operator import ior, iand
import boto3
from boto3.dynamodb.conditions import Key, Attr

AGENCY_TABLE = None

# Scales are currently hard-coded here and in the front end
# In the future they should be moved to a shared location
SCALES = {
    'race': ['Asian/Pacific Islander', 'Black/African American',
             'Hispanic/Latino', 'Native American', 'White/Caucasian',
             'Prefer not to say', 'Other'],
    'gender': ['Male', 'Female', 'Prefer not to say', 'Other'],
    'age': ['Under 18', '18-24', '25-34', '35-44', '45-54', 'Over 54'],
    'sentiment': ['MIXED', 'NEGATIVE', 'NEUTRAL', 'POSITIVE'] }




# Fields expected to be retured with responses
DEFAULT_RESPONSE_FIELDS =  'Choice,LSI,#d,Sort,#p, #t, Topic,Gender,Longitude,RespondentId,Age,Latitude,Origin,Race,IncidentCode,IncidentId,Sentiment,rojopolisEncounterScore,rojopolisGeneralScore,QuestionChoicesId,OpenResponse'
DEFAULT_AGENCY_FIELDS = 'rojopolisEncounterScore,CityRacePercent,CityGenderPercent,#p,rojopolisGeneralScore,CityPopulation,Sort,LSI,ZoneofInterest,CityAgePercent,#n'
DEFAULT_QUESTION_FIELDS = 'QuestionChoicesId,Sort,Category,#p,#t'

def get_table():
    '''Manages lazy global table instantiation'''
    global AGENCY_TABLE # pylint: disable=global-statement
    if not AGENCY_TABLE:
        dynamodb = boto3.resource('dynamodb')
        agency_table_id = os.environ['AGENCY_TABLE_ID']
        AGENCY_TABLE = dynamodb.Table(agency_table_id)
    LOG.debug(f"AGENCY TABLE: {AGENCY_TABLE}")
    return AGENCY_TABLE


def _logger():
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    log_level = os.environ.get('LOGLEVEL', 'INFO')

    log = logging.getLogger('CRUD-API-Lambda')
    log.setLevel(log_level)

    stream_handler = logging.StreamHandler()
    stream_handler.setLevel(log_level)
    stream_handler.setFormatter(formatter)

    log.addHandler(stream_handler)
    return log

LOG = _logger()

class DecimalEncoder(json.JSONEncoder):
    '''
     Helper class to convert a DynamoDB item to JSON.
     From: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/GettingStarted.Python.04.html
     '''
    def default(self, o):
        if isinstance(o, decimal.Decimal):
            if o % 1 > 0:
                return float(o)
            else:
                return int(o)
        return super(DecimalEncoder, self).default(o)


# Make readable output, only for development purposes
class PrettyLog():
    def __init__(self, obj):
        self.obj = obj
    def __repr__(self):
        return pprint.pformat(self.obj)

# Handler through which all calls flow
def entrypoint(event, context):
    LOG.info(f"event: {event}")

    # We only support GET
    if event['httpMethod'] != 'GET':
        raise NotImplementedError(f"httpMethod not supported: {event['httpMethod']}")

    route_base = [x for x in event['path'].split('/') if x != ''][0]
    
    if 'aId' not in event['pathParameters']:
        raise TypeError('aId required')
    aId = event['pathParameters']['aId']

    LOG.debug(route_base)
    queryStringParameters = event['queryStringParameters'] or {}

    if route_base == 'agency':
        response = agency(aId)
    elif route_base == 'questionResponsesMetadata':
        response = questionResponsesMetadata(aId, **queryStringParameters)
    elif route_base == 'responsesSentimentMetadata':
        response = responsesSentimentMetadata(aId, **queryStringParameters)
    elif route_base == 'responsesMetadata':
        response = responsesMetadata(aId, **queryStringParameters)
    elif route_base == 'questions':
        response = questions(aId, **queryStringParameters)
    elif route_base == 'topics':
        response = topics(aId,**queryStringParameters)
    elif route_base == 'responses':
        response = responses(aId, **queryStringParameters)
    elif route_base == 'questionChoices':
        response = questionChoices(aId, **queryStringParameters)
    else:
        raise NotImplementedError(f"Path: {event['path']!r}")

    try:
        return { "statusCode": 200,
                 "headers": { 
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Method": "*",
                    "Access-Control-Allow-Headers" : "Content-Type,X-Amz-Date,Authorization,X-Api-Key"
                 },
                 "body": json.dumps(response)}
    except:
        LOG.exception(response)
        raise


def agency(aId):
    # Enforce key convention
    if not aId.startswith('AID-'):
        raise TypeError("Improper agency key prefix")

    LOG.info(f"AID: '{aId}'")
    response = get_table().query(
        KeyConditionExpression=Key('Partition').eq(aId) & Key('Sort').eq('DeptData'),
        ProjectionExpression=DEFAULT_AGENCY_FIELDS,
        ExpressionAttributeNames={"#p":"Partition", "#n":"Name"}
    )
    response['Items'] = _cast_ints(response['Items'])
    return response


def questionResponsesMetadata(aId,
                              question,
                              startDate=None,
                              endDate=None,
                              age=None,
                              gender=None,
                              race=None,
                              sentiment=None,
                              origin=None,
                              geo=None,
                              topic=None):
    response = _responses(aId,
                          question=question,
                          startDate=startDate,
                          endDate=endDate,
                          age=age,
                          gender=gender,
                          race=race,
                          sentiment=sentiment,
                          origin=origin,
                          geo=geo,
                          topic=topic)
    response['Items'] = count_by_scale(response['Items'])
    return response


def responsesSentimentMetadata(aId,
                              question=None,
                              startDate=None,
                              endDate=None,
                              age=None,
                              gender=None,
                              race=None,
                              sentiment=None,
                              origin=None,
                              geo=None,
                              topic=None):
    response = _responses(aId,
                          question=question,
                          startDate=startDate,
                          endDate=endDate,
                          age=age,
                          gender=gender,
                          race=race,
                          sentiment=sentiment,
                          origin=origin,
                          geo=geo,
                          topic=topic)
    response['Items'] = count_by_scale(response['Items'], group_field='Sentiment')
    return response


def count_by_scale(data, group_field='Choice'):
    '''
    Aggregate response data grouped by scale values
    and it's quetions possible scale

    group_field: top level field for grouping, 'Choice' and 'Sentiment' are
    only supported fields.
    '''
    if not data:
        return {'age':[], 'race': [], 'gender': [], 'sentiment': [], 'dayCount': []}

    scales = SCALES

    if group_field == 'Choice':
        # All responses are for same question => same question scale
        indices = _get_question_choices_count(data[0])
    elif group_field == 'Sentiment':
        indices = range(len(scales['sentiment']))

    metadata = {
        # Age
        'age': field_count_by_scale('Age', data, indices, keys=scales['age'], group_field=group_field),
        # Race
        'race': field_count_by_scale('Race', data, indices, keys=scales['race'], group_field=group_field),
        # Gender
        'gender': field_count_by_scale('Gender', data, indices, keys=scales['gender'], group_field=group_field),
        # Sentiment
        'sentiment': field_count_by_scale('Sentiment', data, indices, keys=scales['sentiment'], group_field=group_field),
        # DayCount
        'dayCount': field_count_by_scale('Date', data, indices, group_field=group_field) }
    return metadata


def _get_question_choices_count(item):
    aid = item['Partition']
    questionChoiceId = item['QuestionChoicesId']
    response = questionChoices(aid, questionChoiceId)
    return tuple(range(len(response['Items'][questionChoiceId])))


def _groupby(field_name, data):
    # skip items lacking the field
    filtered = [x for x in data if field_name in x]

    # do same as cytoolz groupby but using standard lib
    filtered.sort(key=itemgetter(field_name))
    grouped = {i:list(j) for i,j in groupby(filtered, itemgetter(field_name))}
    return grouped

def field_count_by_scale(field_name, data, indices, group_field='Choice', keys=None):
    responses = []
    if group_field == 'Sentiment':
        # Sentiment is sparely populated, so replace non-response with
        # value that won't be reported
        for row in data:
            if 'Sentiment' not in row:
                row['Sentiment'] = len(indices)

    grouped = _groupby(field_name, data)

    # All fields except Date have a set number of possible responses
    keys = range(len(keys)) if keys else sorted(grouped.keys())

    for i in keys:
        group = grouped.get(i, [])
        response = [len(_groupby(group_field, group).get(x, [])) for x in indices]
        responses.append(response)

    return responses

def responsesMetadata(aId,
                      startDate=None,
                      endDate=None,
                      age=None,
                      gender=None,
                      race=None,
                      sentiment=None,
                      origin=None,
                      geo=None,
                      topic=None):
    response = _responses(aId,
                          startDate=startDate,
                          endDate=endDate,
                          age=age,
                          gender=gender,
                          race=race,
                          sentiment=sentiment,
                          origin=origin,
                          geo=geo,
                          topic=topic)
    response['Items'] = count_and_mean(response['Items'])
    return response


def count_and_mean(data):
    '''
    Aggregate data grouped by scale values, count it, and
    calculate mean for rojopolis score(s).
    '''
    scales = SCALES

    metadata = {
        # Age
        'age': field_count_score_avg('Age', data, scales['age']),
        # Race
        'race': field_count_score_avg('Race', data, scales['race']),
        # Gender
        'gender': field_count_score_avg('Gender', data, scales['gender']),
        # Sentiment
        'sentiment': field_count_score_avg('Sentiment', data, scales['sentiment']),
        # DayCount
        'dayCount': field_count_score_avg('Date', data) }
    return metadata

def field_count_score_avg(field_name, data, keys=None):
    responses = []
    grouped = _groupby(field_name, data)  

    # All fields except Date have a set number of possible responses
    keys = range(len(keys)) if keys else sorted(grouped.keys())

    if len(grouped.keys()) > len(keys):
        raise ValueError(f"More groups found than keys for field '{field_name}'")

    for i in keys:
        group = grouped.get(i, [])
        rojopolisGeneralScoreAvgs = [x['rojopolisGeneralScore'] for x in group if 'rojopolisGeneralScore' in x] or [0]
        rojopolisEncounterScores = [x['rojopolisEncounterScore'] for x in group if 'rojopolisEncounterScore' in x] or [0]
        response = {
            'count': len(group),
            'rojopolisGeneralScoreAvg': mean(rojopolisGeneralScoreAvgs) if group else 0,
            'rojopolisEncounterScoreAvg': mean(rojopolisEncounterScores) if group else 0
            }
        responses.append(response)
    return responses

def questions(aId, limit=None, exclusiveStartKey=None):
    params = { 'KeyConditionExpression':Key('Partition').eq(aId) & Key('Sort').begins_with('QID'),
               'ProjectionExpression':DEFAULT_QUESTION_FIELDS,
               'ExpressionAttributeNames':{"#p":"Partition", "#t":"Text"} }

    if limit is not None:
        params['Limit'] = int(limit)

    if exclusiveStartKey is not None:
        params['ExclusiveStartKey'] = literal_eval(exclusiveStartKey)
        
    response = get_table().query(**params)
    return response


def topics(aId):
    response = get_table().query(
        KeyConditionExpression=Key('Partition').eq(aId) & Key('Sort').begins_with('TID')
    )
    return response



def questionChoices(aId, qcid=None, limit=None, exclusiveStartKey=None):
    params = {} 

    if qcid:
        params['KeyConditionExpression']=Key('Partition').eq(aId) & Key('Sort').eq(qcid)
    else:
        params['KeyConditionExpression']=Key('Partition').eq(aId) & Key('Sort').begins_with('QCID')

    if limit is not None:
        params['Limit'] = int(limit)

    if exclusiveStartKey is not None:
        params['ExclusiveStartKey'] = literal_eval(exclusiveStartKey)
        
    response = get_table().query(**params)

    # Convert Choices strings to tuples
    response['Items'] = _convert_to_map(response['Items'])
    return response


def _convert_to_map(items):
    return {x['Sort']:literal_eval(x['Choices']) for x in items}


def responses(aId,  
              startDate=None,
              endDate=None,
              age=None,
              gender=None,
              race=None,
              sentiment=None,
              origin=None,
              geo=None,
              topic=None,
              exclusiveStartKey=None,
              limit=None):
    response = _responses(aId,  
                          startDate=startDate,
                          endDate=endDate,
                          age=age,
                          gender=gender,
                          race=race,
                          sentiment=sentiment,
                          origin=origin,
                          geo=geo,
                          topic=topic,
                          exclusiveStartKey=exclusiveStartKey,
                          limit=limit)
    return response


def _responses(aId,  
               question=None,
               startDate=None,
               endDate=None,
               age=None,
               gender=None,
               race=None,
               sentiment=None,
               origin=None,
               geo=None,
               topic=None,
               projectionExpression=None,
               exclusiveStartKey=None,
               limit=None):
    ProjectionExpression = projectionExpression or DEFAULT_RESPONSE_FIELDS
    filters = []
    if question:
        filters.append(Attr('LSI').eq(question))
    if startDate:
        filters.append(Attr('Date').gte(str(startDate)))
    if endDate:
        filters.append(Attr('Date').lte(str(endDate)))
    if age:
        age_filter = reduce(ior, [Attr('Age').eq(str(x)) for x in age])
        filters.append(age_filter)
    if gender:
        gender_filter = reduce(ior, [Attr('Gender').eq(str(x)) for x in gender])
        filters.append(gender_filter)
    if race:
        race_filter = reduce(ior, [Attr('Race').eq(str(x)) for x in race])
        filters.append(race_filter)
    if sentiment:
        sentiment = sentiment.split(',') if isinstance(sentiment, str) else sentiment
        sentiment_filter = reduce(ior, [Attr('Sentiment').eq(str(x)) for x in sentiment])
        filters.append(sentiment_filter)
    if origin:
        origin_filter = reduce(ior, [Attr('Origin').eq(str(x)) for x in origin])
        filters.append(origin_filter)
    if geo:
        # [bottom left coordinates, upper right coordinates] 
        # 27.449790329784214%2C-142.55859375000003%2C53.592504809039376%2C-32.69531250000001
        # Argument comes in as single string
        # Need to convert to use offset fields
        geo = geo.split(',')
        filters.append(Attr('LatitudeOffset').gte(_convert_latitude(geo[0])))
        filters.append(Attr('LongitudeOffset').gte(_convert_longitude(geo[1])))
        filters.append(Attr('LatitudeOffset').lte( _convert_latitude(geo[2])))
        filters.append(Attr('LongitudeOffset').lte(_convert_longitude(geo[3])))
    if topic:
        filters.append(Attr('Topic').eq(str(topic)))

    params = {'KeyConditionExpression':Key('Partition').eq(aId) & Key('Sort').begins_with('RID'),
              'ProjectionExpression':ProjectionExpression,
              'ExpressionAttributeNames':{"#p":"Partition", "#d": "Date", "#t": "Text"}}

    if filters:
            params['FilterExpression'] = reduce(iand, filters)

    if limit is not None:
        params['Limit'] = int(limit)

    if exclusiveStartKey is not None:
        params['ExclusiveStartKey'] = literal_eval(exclusiveStartKey)
        
    response = get_table().query(**params)
    LOG.debug(f"Response before casting ints: {response}")

    response['Items'] = _cast_ints(response['Items'])
    return response


def _convert_latitude(value):
    return f"{float(value):019.15F}"


def _convert_longitude(value):
    return f"{(float(value) + 200):019.15F}"


def _cast_ints(items):
    '''
    Temp method to cast int fields until we find a better way.
    '''
    new_items = [] 
    for item in items:
        new_item = {}
        for key, value in item.items():
            if isinstance(value, list):
                new_item[key] = [_cast_num(x) for x in value]
            else:
                new_item[key] = _cast_num(value)
        new_items.append(new_item)

    return new_items


def _cast_num(value):
    if hasattr(value, 'isdigit') and value.isdigit():
        return int(value)
    else:
        return _cast_float(value)


def _cast_float(value):
    try:
        return float(value)
    except ValueError:
        return value

