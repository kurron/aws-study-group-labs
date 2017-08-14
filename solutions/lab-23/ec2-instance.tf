# https://www.terraform.io/docs/providers/aws/d/instance.html
# Supply the following:
#   * AMI
#   * instance type
#   * subnet id
#   * tags
# Do NOT give it a key pair.

provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "example" {
  ami           = "ami-6df1e514"
  instance_type = "t2.nano"
  key_name      = "asgard-lite-test"
  subnet_id     = "subnet-508eaf19"
  tags {
      Name = "AWS Study Group"
      Purpose = "Showcase Terraform"
      Project = "AWS Study Group"
      Creator = "rkurr@transparent.com"
      Environment = "development"
      Freetext = "This is too easy!"
  }
}
