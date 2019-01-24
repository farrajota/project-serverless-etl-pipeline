AWS_REGION="eu-west-1"
LAMBDA_CODE_BUCKET=case-study-project-lambda-code
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
setup-all:
	make build \
		package \
		deploy


########################
# Generate test data
########################

generate-dummy-data:
	python scripts/generate_dummy_data.py

requests_per_second=10
generate-stream-data:
	python scripts/generate_stream_data.py --requests_per_second $(requests_per_second)


########################
# Deploy with Terraform
########################

LAMBDA_KINESIS_FIREHOSE=firehose_lambda
LAMBDA_PROCESS_STREAM=process_stream
LAMBDA_DAILY_PROCESS=daily_process
LAMBDA_GENDER_API=gender_api

terraform-init:
	terraform init terraform/

terraform-build-package:
	bash scripts/build_package_code.sh \
		$(AWS_REGION) \
		$(LAMBDA_CODE_BUCKET) \
		$(LAMBDA_KINESIS_FIREHOSE) \
		$(LAMBDA_PROCESS_STREAM) \
		$(LAMBDA_DAILY_PROCESS) \
		$(LAMBDA_GENDER_API)

terraform-deploy:
	terraform apply \
		-var-file=terraform/terraform.tfvars \
		terraform/

terraform-destroy:
	terraform destroy \
		-var-file=terraform/terraform.tfvars \
		terraform/
