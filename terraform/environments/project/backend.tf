# ---------------------------------------------------------------------------
# Terraform state backend.
#
# Starts local (state.tfstate in this directory) so `terraform init` works
# with zero prerequisites. Once you've created the S3 bucket (and optionally
# DynamoDB table) for remote state, uncomment the backend block below and
# run `terraform init -migrate-state`.
# ---------------------------------------------------------------------------

terraform {
  # backend "s3" {
  #   bucket       = "your-terraform-state-bucket"
  #   key          = "gitlab-platform/project/terraform.tfstate"
  #   region       = "ap-south-1"
  #   encrypt      = true
  #   use_lockfile = true # native S3 state locking (Terraform >= 1.10)
  # }
}
