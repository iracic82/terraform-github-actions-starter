terraform {
  backend "s3" {
    bucket         = "terraform-state-688664532084-us-east-1"
    key            = "aws-prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    kms_key_id     = "arn:aws:kms:us-east-1:688664532084:key/66457d60-cb55-4831-ae05-bf316a41ee1b"
  }
}
