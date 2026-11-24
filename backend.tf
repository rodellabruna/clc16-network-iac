terraform {
  backend "s3" {
    bucket = "terraform-state-rosana-clc16-680160277065-us-east-1-an"
    key    = "terraform/state"
    region = "us-east-1"
    use_lockfile = true
    encrypt = true
  }
}