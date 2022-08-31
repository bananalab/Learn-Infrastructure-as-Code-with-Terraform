import sys;sys.path.append("..")
import pytest
from decimal import Decimal
from qualtrics import decider,QUALTRICS_MAP
import math

@pytest.fixture
def setup_qualtrics_stub():
    rec = {"rojopolisGeneralScore": 13, "Text": math.nan}
    return QUALTRICS_MAP, rec

def test_decider(setup_qualtrics_stub):

    qualtrics_map, rec = setup_qualtrics_stub
    res = decider(rec, qualtrics_map)
    assert res == {"rojopolisGeneralScore": 13}
