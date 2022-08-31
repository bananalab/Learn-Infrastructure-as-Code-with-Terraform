{
	"Version": "2012-10-17",
	"Statement": [{
			"Effect": "Allow",
			"Action": [
				"dynamodb:BatchGetItem",
				"dynamodb:GetItem",
				"dynamodb:Query",
				"dynamodb:Scan",
				"dynamodb:BatchWriteItem",
				"dynamodb:PutItem",
				"dynamodb:UpdateItem"
			],
			"Resource": "arn:aws:dynamodb:${aws_region}:${aws_account_id}:*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"logs:CreateLogStream",
				"logs:PutLogEvents"
			],
			"Resource": "arn:aws:logs:${aws_region}:${aws_account_id}:*"
		},
		{
			"Effect": "Allow",
			"Action": "logs:CreateLogGroup",
			"Resource": "*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"sqs:ReceiveMessage",
				"sqs:DeleteMessage",
				"sqs:GetQueueAttributes",
				"sqs:GetQueueUrl",
				"sqs:SendMessage",
				"sqs:SendMessageBatch"
			],
			"Resource": "arn:aws:sqs:${aws_region}:${aws_account_id}:*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"s3:*"
			],
			"Resource": "arn:aws:s3:::*"
		},
		{
			"Effect": "Allow",

			"Action": [
				"kms:*"
			],
			"Resource": "*"
		}, 
		{
        	"Effect": "Allow",
          	"Action": [
                "comprehend:*"
			],
			"Resource": "*"
    	}
	]
}