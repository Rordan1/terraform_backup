provider "aws" {
 profile = "IAM-ADMIN-GEN"
 region = "us-east-1"
}

resource "aws_s3_bucket" "config_bucket" {
  bucket = "my-config-bucket"
}

resource "aws_s3_bucket_object" "config_file" {
  bucket = aws_s3_bucket.config_bucket.id
  key    = "config/httpd.conf"
  content = filebase64("/mnt/c/Users/rorda/projects/http.conf")
}

resource "aws_instance" "web_server" {
  instance_type = "t2.micro"
  data "aws_ami" "latest_ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

  user_data = <<EOF
    #!/bin/bash
    aws s3 cp s3://${aws_s3_bucket.config_bucket.id}/config/httpd.conf /etc/httpd/conf/httpd.conf
    service httpd start
  EOF
}

