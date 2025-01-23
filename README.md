# prefect-start
An opinionated example of a Prefect project


## Setup

Populate a `terraform.tfvars` file in the `infra/aws` directory with the following structure:

```hcl
prefect_account_id = ""
prefect_api_key = ""
aws_region = ""
aws_vpc_id = ""
aws_subnet_ids = ["", ""]
```

Then run the commands below:

```bash
# Prepare the environment
uv sync
source .venv/bin/activate

# Create the resources
cd infra/aws
terraform init
terraform apply

# Set some environment variables for convenience
export ENVIRONMENT=`terraform output -raw environment`
export AWS_REGION=`terraform output -raw aws_region`
export AWS_ECR_REPOSITORY=`terraform output -raw aws_ecr_repository`

# Authenticate with Prefect Cloud
cd ../..
prefect profile create $ENVIRONMENT
prefect profile use $ENVIRONMENT
prefect cloud login

# Authenticate to ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ECR_REPOSITORY

# Deploy the flow
prefect --no-prompt deploy --all

# Kick off a flow run
prefect deployment run 'hello/ecs'
```
