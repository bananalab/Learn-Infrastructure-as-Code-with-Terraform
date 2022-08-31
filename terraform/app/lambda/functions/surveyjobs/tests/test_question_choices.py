import sys;sys.path.append("..")
import pytest
from os import path
from qualtrics import process_questions_from_survey
import json

def _file_path(file_name):
    basepath = path.dirname(__file__)
    return path.abspath(path.join(basepath, file_name))

def test_process_questions_from_survey():
    aid = 'AID-BOS-dd3244'
    file_path = _file_path('./surveys_endpoint_response.json')
    with open(file_path, 'r') as opened_file:
        survey_data = json.load(opened_file)
        questions, choices = process_questions_from_survey(aid, 
                                                           survey_data['result'])

    expected_questions = [
                            {'Partition': aid, 
                             'Sort': 'QID24' , 
                             'QuestionChoicesId': 'QCID-678bc4f5c1664d4c9ed1bdf3387521f6' ,
                             'Category': '', 
                             "Text": "Hi, this is rojopolis. We're an independent group that improves public safety with community feedback. We will share your thoughts directly to your police chief, but you will be ANONYMOUS. First, we need your consent. This will be a short conversation! Do you want to continue?"},
                            {'Partition': aid, 
                             'Sort' : 'QID135400005', 
                             'Category': '', 
                             'Text' : 'Confirmed! Reply STOP  end anytime; standard messaging rates apply. On a scale of 0-100, how would you rate the overall performance of the responding officer(s)?'},
                            {'Partition': aid, 
                             'Sort' : 'QID25',
                             'QuestionChoicesId': 'QCID-3bf5635ba2f559823257c2e62ab3379d',
                             'Category': '', 
                             'Text' : 'What is the #1 public safety issue that needs to be addressed for you to feel safer in your neighborhood?'},
                            {'Partition': aid, 
                             'Sort' : 'QID26',
                             'Category': '', 
                             'Text' : 'Ok, can you please explain?'},
                            {'Partition': aid, 
                             'Sort' : 'QID27',
                             'QuestionChoicesId': 'QCID-baf58d5ea2c4c4dd8b4bb2ece082d7bd',
                             'Category': '', 
                             'Text' : "Got it. Thanks. We're so sorry that you're having to go through all of this. We can put you directly in touch with services and people that can provide assistance if you need it. If you want us to do this, please select from the following list, and we'll have someone follow up with you:"},
                            {'Partition': aid, 
                             'Sort' : 'QID28',
                             'Category': '', 
                             'Text' : "Thanks for your feedback. You can view what others in your city and neighborhood are saying here: www.textrojopolis.com/community. If you have anything else to say, please text it now."},
                            {'Partition': aid, 
                             'Sort' : 'QID29',
                             'Category': '', 
                             'Text' : "Ok, someone will be in touch. Thanks for your feedback. You can view what others in your city and neighborhood are saying here: www.textrojopolis.com/community. If you have anything else to say, please text it now."},
                            {'Partition': aid, 
                             'Sort' : 'QID17',
                             'Category': '', 
                             'Text' : "Confirmed! Reply STOP  end anytime; standard messaging rates apply. On a scale of 0-100, how would you rate the overall performance of the responding officer(s)?"},
                            {'Partition': aid, 
                             'Sort' : 'QID18',
                             'QuestionChoicesId': 'QCID-3bf5635ba2f559823257c2e62ab3379d',
                             'Category': '', 
                             'Text' : "What is the #1 public safety issue that needs to be addressed for you to feel safer in your neighborhood?"},
                            {'Partition': aid, 
                             'Sort' : 'QID19',
                             'Category': '', 
                             'Text' : "Ok, can you please explain?"},
                            {'Partition': aid, 
                             'Sort' : 'QID30',
                             'QuestionChoicesId': 'QCID-baf58d5ea2c4c4dd8b4bb2ece082d7bd',
                             'Category': '', 
                             'Text' : "Got it. Thanks. We're so sorry that you're having to go through all of this. We can put you directly in touch with services and people that can provide assistance if you need it. If you want us to do this, please select from the following list, and we'll have someone follow up with you:"},
                            {'Partition': aid, 
                             'Sort' : 'QID31',
                             'Category': '', 
                             'Text' : "Thanks for your feedback. You can view what others in your city and neighborhood are saying here: www.textrojopolis.com/community. If you have anything else to say, please text it now."},
                            {'Partition': aid, 
                             'Sort' : 'QID32', 
                             'Category': '', 
                             'Text' : "Ok, someone will be in touch. Thanks for your feedback. You can view what others in your city and neighborhood are saying here: www.textrojopolis.com/community. If you have anything else to say, please text it now."}]
    expected_choices = [
            { 'Sort' : 'QCID-678bc4f5c1664d4c9ed1bdf3387521f6',
              'Partition': aid,
              'Choices'   :  ('Yes, continue in English', 'Sí, continuar en Español', 'No') },
            { 'Sort' : 'QCID-3bf5635ba2f559823257c2e62ab3379d',
              'Partition': aid,
              'Choices'   :  ('Property crime', 'Violent crime', 'Environmental issues (i.e. lighting, stop signs, etc.)', 'Officer behavior and trust in police', 
'Other') },
            { 'Sort' : 'QCID-baf58d5ea2c4c4dd8b4bb2ece082d7bd',
              'Partition': aid,
              'Choices'   :  ('Community organizations for neighborhood issues', 'Services that help people after experiencing a crime', 'Organizations that help with legal issues relating to a crimes, tickets, etc.', 'Groups that provide insurance, safety, or security around my home', 'My local government representatives office', 'No, I just need to get back to my normal routine') },
            { 'Sort' : 'QCID-3bf5635ba2f559823257c2e62ab3379d',
              'Partition': aid,
              'Choices'   :  ('Property crime', 'Violent crime', 'Environmental issues (i.e. lighting, stop signs, etc.)', 'Officer behavior and trust in police', 'Other') },
            { 'Sort' : 'QCID-baf58d5ea2c4c4dd8b4bb2ece082d7bd',
              'Partition': aid,
              'Choices'   :  ('Community organizations for neighborhood issues', 'Services that help people after experiencing a crime', 'Organizations that help with legal issues relating to a crimes, tickets, etc.', 'Groups that provide insurance, safety, or security around my home', 'My local government representatives office', 'No, I just need to get back to my normal routine') },
            ]
    assert expected_questions == questions
    assert expected_choices == choices
