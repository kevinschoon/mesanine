provider "aws" {
  region = "us-east-1"
}

variable "git_hash" {
  type = "string"
}

data "aws_ami" "master" {
  owners = ["self"]

  filter {
    name   = "name"
    values = ["mesanine-${var.git_hash}"]
  }
}

resource "aws_instance" "master0" {
  ami           = "${data.aws_ami.master.id}"
  instance_type = "t2.small"
  key_name      = "vektor"
  subnet_id     = "subnet-d995cbf2"

  vpc_security_group_ids = [
    "sg-6cd2cf0b",
  ] # SSH

  root_block_device = {
    volume_size = "3"
  }

  tags {
    Name = "master0"
    Hash = "${var.git_hash}"
  }
}
