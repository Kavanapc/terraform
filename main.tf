locals {
 vpc_id = "vpc-0ce09d1b3d9fbea49"
 subnet_id = "subnet-010e03a7844f9d355"
 ssh_user = "ubuntu"
 key_name = "kavanapc2023"
 private_key_path = file("./kavanapc2023.ppk")
 }

provider "aws" {
 region = "ap-south-1"
 }
resource "aws_security_group" "sg" {
  name   = "sg"
  vpc_id = local.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "banking_project" {
  ami                         = "ami-0f8ca728008ff5af4"
  subnet_id                   = local.subnet_id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.sg.id]
  key_name                    = local.key_name

  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.banking_project.public_ip
    }
  }
provisioner "local-exec" {
    command = "ansible-playbook  -i ${aws_instance.banking_project.public_ip}, --private-key ${local.private_key_path} banking.yml"
  }
}
