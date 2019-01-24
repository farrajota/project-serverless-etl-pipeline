#!/bin/bash
# Package code to aws lamdba compatible zip files
# and store them to S3

AWS_REGION="$1"
LAMBDA_CODE_BUCKET="$2"
LAMBDA_KINESIS_FIREHOSE_FILENAME="$3"
LAMBDA_KINESIS_FIREHOSE_DIR="kinesis_firehose_stream_process"
LAMBDA_PROCESS_STREAM_FILENAME="$4"
LAMBDA_PROCESS_STREAM_DIR="process_stream_data"
LAMBDA_DAILY_PROCESS_FILENAME="$5"
LAMBDA_DAILY_PROCESS_DIR=daily_process_lambda
LAMBDA_GENDER_API_FILENAME="$6"
LAMBDA_GENDER_API_DIR=gender_api_lambda
PYTHON_VERSION=3.7

# check if the bucket exists
if [[aws s3 ls "s3://$LAMBDA_CODE_BUCKET" 2>&1 | grep -q 'An error occurred']]; then
    aws s3api create-bucket --bucket $LAMBDA_CODE_BUCKET --region $AWS_REGION
fi

# check if the folder for building + packaging 
# aws lambda code exists
if [[ ! -d "docker-aws-lambda-builder" ]]; then
    git clone https://github.com/farrajota/docker-aws-lambda-builder
fi

# Appends the suffix '.zip' to a string
append_suffix_zip() {
    if [[ "$1" == *.zip ]]; then
        echo "$1"
    else
        echo "$1.zip"
    fi
}

# build and package the lambda code
build_package() {
    local root_path=$PWD

    # enter dir
    cd docker-aws-lambda-builder

    # copy files to code/ folder
    cp -r $root_path/$2/* $PWD/code

    # build zip file
    make build-package \
        filename=$1 \
        version=$PYTHON_VERSION

    # check if temporary build dir exists
    if [[ ! -d ../build ]]; then
        mkdir -p ../build
    fi

    # move artifact to the temp dir
    mv $1 ../build

    # return to the root path
    cd ..
}

# Uploads file to an S3 bucket
upload_to_s3() {
    aws s3 cp build/$1 s3://$LAMBDA_CODE_BUCKET/$1
}

# Append the '.zip' suffix to the filenames
LAMBDA_KINESIS_FIREHOSE_FILENAME=$( append_suffix_zip $LAMBDA_KINESIS_FIREHOSE_FILENAME )
LAMBDA_PROCESS_STREAM_FILENAME=$( append_suffix_zip $LAMBDA_PROCESS_STREAM_FILENAME )
LAMBDA_DAILY_PROCESS_FILENAME=$( append_suffix_zip $LAMBDA_DAILY_PROCESS_FILENAME )
LAMBDA_GENDER_API_FILENAME=$( append_suffix_zip $LAMBDA_GENDER_API_FILENAME )

# build lambda functions
build_package $LAMBDA_KINESIS_FIREHOSE_FILENAME $LAMBDA_KINESIS_FIREHOSE_DIR
build_package $LAMBDA_PROCESS_STREAM_FILENAME $LAMBDA_PROCESS_STREAM_DIR
build_package $LAMBDA_DAILY_PROCESS_FILENAME $LAMBDA_DAILY_PROCESS_DIR
build_package $LAMBDA_GENDER_API_FILENAME $LAMBDA_GENDER_API_DIR

# Upload zip files to a bucket
upload_to_s3 $LAMBDA_KINESIS_FIREHOSE_FILENAME
upload_to_s3 $LAMBDA_PROCESS_STREAM_FILENAME
upload_to_s3 $LAMBDA_DAILY_PROCESS_FILENAME
upload_to_s3 $LAMBDA_GENDER_API_FILENAME

# clean up
rm -rf build
