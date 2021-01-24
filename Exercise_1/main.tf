provider "aws" {
  access_key = "AccessKey"
  secret_key = "SecretKey"
  region = "us-west-2"
}

resource "aws_instance" "Udacity_T2" {
  count = "4"
  ami = "ami-0a36eb8fadc976275"
  instance_type = "t2.micro"
  tags = {
    Name = "Udacity T2"
  }
}

resource "aws_instance" "Udacity_M4" {
  count = "2"
  ami = "ami-0a36eb8fadc976275"
  instance_type = "m4.large"
  tags = {
    Name = "Udacity M4"
  }
}