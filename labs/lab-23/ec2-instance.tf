# https://www.terraform.io/docs/providers/aws/d/instance.html
# Supply the following:
#   * AMI
#   * instance type
#   * subnet id
#   * tags
# Do NOT give it a key pair -- at least not yet.

provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "example" {
  ami           = "ami-6df1e514"
}
