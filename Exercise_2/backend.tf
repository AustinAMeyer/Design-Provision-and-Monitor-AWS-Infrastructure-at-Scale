terraform {
  backend "s3" {
    bucket = "terraform-statefiles-aam"
    key = "austinmeyer/Documents/AWS/udadcity_s3/terraform.tfstate"
    region = "us-west-2"
    }
}
