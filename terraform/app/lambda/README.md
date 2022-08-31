# Lambda function definitions.
Place lambda code in subfolders of `functions` directory

## Running tests
~~~
cd lambda
pip install -r test/requirements.txt
python -m pytest --cov=functions/crud_handler/  test/test_crud_handler.py
~~~

## Run locally
Use sam local to run locally against cloud db.

~~~~
sam local start-api
~~~~