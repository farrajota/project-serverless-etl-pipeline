LAMBDA_CODE_BUCKET=data-pipeline-etl-project-lambda-code
PROJECT_NAME=case-study-project

dev:
	sam local start-api

test:
	python -m pytest tests/ -v

validate:
	sam validate

create-code-bucket:
	aws s3 mb s3://$(LAMBDA_CODE_BUCKET)

build:
	sam build --use-container

package:
	sam package \
		--output-template-file packaged.yaml \
		--s3-bucket $(LAMBDA_CODE_BUCKET)

deploy:
	sam deploy \
		--template-file packaged.yaml \
		--stack-name $(PROJECT_NAME) \
		--capabilities CAPABILITY_IAM

delete-stack:
	aws cloudformation delete-stack --stack-name $(PROJECT_NAME)

describe:
	aws cloudformation describe-stacks \
		--stack-name $(PROJECT_NAME) \
		--query 'Stacks[].Outputs'