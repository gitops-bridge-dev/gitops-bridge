terraform {
  required_version = ">= 1.0"

  required_providers {
    akp = {
      source  = "akuity/akp"
      version = "~> 0.6.1"
    }
  }

  # ##  Used for end-to-end testing on project; update to suit your needs
  # backend "s3" {
  #   bucket = "terraform-ssp-github-actions-state"
  #   region = "us-west-2"
  #   key    = "e2e/ipv4-prefix-delegation/terraform.tfstate"
  # }
}
