#/bin/bash
# Package code and store it to aws s3
LAMBDA_CODE_BUCKET="case-study-project-lambda-code"
AWS_REGION="eu-west-1"
LAMBDA_KINESIS_FIREHOSE_FILENAME="firehose_lambda.zip"

# check if the bucket exists
if [[aws s3 ls "s3://$LAMBDA_CODE_BUCKET" 2>&1 | grep -q 'An error occurred']]
then
    aws s3api create-bucket --bucket my-bucket --region $AWS_REGION
fi

# kinesis firehose lambda code
zip -j $LAMBDA_KINESIS_FIREHOSE_FILENAME ../kinesis_firehose_stream_process/app.py

# Store files in S3
aws s3 cp $LAMBDA_KINESIS_FIREHOSE_FILENAME s3://$LAMBDA_CODE_BUCKET

# Delete files
rm $LAMBDA_KINESIS_FIREHOSE_FILENAME
