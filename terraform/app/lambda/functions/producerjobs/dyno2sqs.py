"""
Dynamo to SQS
"""

import click
import boto3
import json
import sys
import os

DYNAMODB = boto3.resource('dynamodb')
SQS = boto3.client("sqs")

#SETUP LOGGING
import logging
from pythonjsonlogger import jsonlogger

LOG = logging.getLogger()
LOG.setLevel(logging.INFO)
logHandler = logging.StreamHandler()
formatter = jsonlogger.JsonFormatter()
logHandler.setFormatter(formatter)
LOG.addHandler(logHandler)

def scan_table(table):
    """Scans table and return results"""
    
    LOG.info(f"Scanning Table {table}")
    producer_table = DYNAMODB.Table(table)
    response = producer_table.scan()
    items = response['Items']
    LOG.info(f"Found {len(items)} surveys")
    return items

def send_sqs_msg(msg, queue_name, delay=0):
    """Send SQS Message

    Expects an SQS queue_name and msg in a dictionary format.
    Returns a response dictionary. 
    """

    queue_url = SQS.get_queue_url(QueueName=queue_name)["QueueUrl"]
    queue_send_log_msg = "Send message to queue url: %s, with body: %s" %\
        (queue_url, msg)
    LOG.info(queue_send_log_msg)
    json_msg = json.dumps(msg)
    response = SQS.send_message(
        QueueUrl=queue_url,
        MessageBody=json_msg,
        DelaySeconds=delay)
    queue_send_log_msg_resp = "Message Response: %s for queue url: %s" %\
        (response, queue_url) 
    LOG.info(queue_send_log_msg_resp)
    return response

def send_emissions(table, queue_name):
    """Send Emissions"""
    
    surveys = scan_table(table=table)
    for survey in surveys:
        LOG.info(f"Sending survey {survey} to queue: {queue_name}")
        response = send_sqs_msg(survey, queue_name=queue_name)
        LOG.debug(response)

def entrypoint(event, context):
    '''
    Lambda entrypoint
    '''
    LOG.info(f"event {event}, context {context}", extra=os.environ)
    cli.main(args=['emit',
                   '--table', os.environ.get('PRODUCER_JOB_TABLE'),
                   '--queue', os.environ.get('PRODUCER_JOB_QUEUE')
                  ]
    )
    

@click.group()
def cli():
    pass

@cli.command()
@click.option("--table", envvar="PRODUCER_JOB_TABLE",
    help="Dynamo Table")
@click.option("--queue", envvar="PRODUCER_JOB_QUEUE",
    help="SQS")
def emit(table, queue):
    """Emit Surveys from DynamoDB into SQS
    
    To run with environmental variables
    export PRODUCER_JOB_TABLE="foo";\
    export PRODUCER_JOB_QUEUE="bar";\
    python dyno2sqs.py emit
    
    """

    LOG.info(f"Running Click emit with table: {table}, queue: {queue}")
    try:
        send_emissions(table=table, queue_name=queue)
    except AttributeError:
        LOG.exception(f"Error, check passed in values: table: {table}, queue: {queue}")
        sys.exit(1)


if __name__ == "__main__":
    cli()