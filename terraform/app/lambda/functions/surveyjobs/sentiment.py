"""Sentiments Tool"""

#SETUP LOGGING
import logging
from pythonjsonlogger import jsonlogger

LOG = logging.getLogger()
LOG.setLevel(logging.DEBUG)
logHandler = logging.StreamHandler()
formatter = jsonlogger.JsonFormatter()
logHandler.setFormatter(formatter)
LOG.addHandler(logHandler)

import click
import boto3
import pandas as pd

TEST_DF = pd.DataFrame(
    {"SentimentRaw": ["I am very Angry",
                    "We are very Happy",
                    "It is raining in Seattle"]}
)

def create_sentiment(row):
    """Uses AWS Comprehend to Create Sentiments on a DataFrame"""

    LOG.info(f"Processing {row}")
    comprehend = boto3.client(service_name='comprehend')
    payload = comprehend.detect_sentiment(Text=row, LanguageCode='en')
    LOG.debug(f"Found Sentiment: {payload}")    
    sentiment = payload['Sentiment']
    return sentiment

def apply_sentiment(df, column="SentimentRaw"):
    """Uses Pandas Apply to Create Sentiment Analysis"""

    df['Sentiment'] = df[column].apply(create_sentiment)
    return df

@click.group()
def cli():
    pass

@cli.command()
def dataframe_sentiments(df=TEST_DF):
    """Processes DataFrame and adds Sentiment
    
    To run:
        python sentiment.py dataframe-sentiments
    """
    
    df_incoming = apply_sentiment(df)
    click.echo(df_incoming)



if __name__ == "__main__":
    cli()