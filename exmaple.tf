terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
//      version = "~> 2.70"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = var.region
}

resource "aws_key_pair" "example" {
  key_name = "examplekey"
  public_key = file("~/.ssh/terraform.pub")
}

resource "aws_instance" "example" {
  key_name      = aws_key_pair.example.key_name
  ami           = "ami-01cfef3a3e4221cf6"
  instance_type = "t2.micro"
  security_groups = ["default"]

  // Inbound rules for SSH need to be set up first.
  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("~/.ssh/terraform")
    host = self.public_ip
    agent = true
  }

//  provisioner "local-exec" {
//    command = "echo ${aws_instance.example.public_ip} > ip_address.txt"
//  }

  # Inbound rules needs to be set up for HTTP first
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install nginx",
      "sudo service nginx start"
    ]
  }
}
