terraform {
  backend "s3" {
    bucket = "ainsley-dev-terraform"
    key    = "platform/terraform.tfstate"
    region = "us-east-1"

    # Backblaze B2 S3-compatible endpoint
    # Use eu-central-003 as the region endpoint
    endpoint = "s3.eu-central-003.backblazeb2.com"

    # Disable AWS-specific features
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
  }
}
