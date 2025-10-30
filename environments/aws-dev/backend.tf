terraform {
  backend "s3" {
    # UPDATE THESE VALUES after running the backend setup script
    bucket         = "terraform-state-ACCOUNT_ID-REGION"  # Replace with your bucket name
    key            = "aws-dev/terraform.tfstate"
    region         = "us-east-1"  # Replace with your region
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    # Uncomment after KMS key is created
    # kms_key_id     = "arn:aws:kms:REGION:ACCOUNT_ID:key/KEY_ID"
  }
}
