LAMBDA_CODE_BUCKET=some-s3-bucket-to-store-lambda-packaged-code
PROJECT_NAME=case-study-project


test:
	python -m pytest tests/ -v

build:
	sam build --use-container

package:
	sam package \
		--output-template-file packaged.yaml \
		--s3-bucket $(LAMBDA_CODE_BUCKET)

dev:
	sam local start-api

deploy:
	sam deploy \
		--template-file packaged.yaml \
		--stack-name $(PROJECT_NAME) \
		--capabilities CAPABILITY_IAM

stack-delete:
	aws cloudformation delete-stack --stack-name $(PROJECT_NAME)

describe:
	aws cloudformation describe-stacks \
		--stack-name $(PROJECT_NAME) \
		--query 'Stacks[].Outputs'