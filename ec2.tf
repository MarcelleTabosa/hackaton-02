resource "aws_instance" "hack02-itt" {
  ami                    = "ami-0fc5d935ebf8bc3bc"
  instance_type          = "t2.micro"
  key_name               = tls_private_key.generated_key.private_key_openssh
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  tags = {
    Name = "hack02-itt"
  }
  user_data = file("${path.module}/configs.sh")
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

resource "tls_private_key" "generated_key" {
  algorithm = "RSA"
}

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name   = "deployer-two"
  public_key = trimspace(tls_private_key.generated_key.public_key_openssh)
}

# resource "tls_private_key" "key_gen" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# resource "aws_key_pair" "generated_key" {
#   key_name   = var.key_name
#   public_key = tls_private_key.key_gen.public_key_openssh
# }

# output "private_key" {
#   value     = tls_private_key.key_gen.private_key_pem
#   sensitive = true
# }

output "hack02-itt" {
  value = aws_instance.hack02-itt.public_dns
}