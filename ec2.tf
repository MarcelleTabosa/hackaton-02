resource "aws_instance" "hack02-itt" {
  ami                    = "ami-0fc5d935ebf8bc3bc"
  instance_type          = "t2.micro"
  key_name               = "itt-keys"
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  tags = {
    Name = "hack02-itt-2"
  }
  user_data = file("${path.module}/configs.sh")
}
output "hack02-itt" {
  value = aws_instance.hack02-itt.public_dns
}

resource "random_pet" "sg" {}

resource "aws_security_group" "web-sg" {
  name = "${random_pet.sg.id}-sg"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  // connectivity to ubuntu mirrors is required to run `apt-get update` and `apt-get install apache2`

  ingress { # Allow SSH access
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}