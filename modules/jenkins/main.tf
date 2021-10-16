data "aws_ami" "jenkins-ec2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Ubuntu-*"]
  }
}

data "aws_subnet" "subnet_public" {
  cidr_block = "10.0.120.0/24"
}
resource "aws_key_pair" "jenkins-sshkey" {
  key_name   = "jenkins-app-key"
  public_key = file("${path.module}/files/jenkins.pub")
}
resource "aws_instance" "jenkins-ec2" {
  ami                         = data.aws_ami.jenkins-ec2.id
  instance_type               = "t2.small"
  subnet_id                   = data.aws_subnet.subnet_public.id
  associate_public_ip_address = true

  tags = {
    Name = "jenkins-ec2"
  }

  key_name = aws_key_pair.jenkins-sshkey.id
  # arquivo de bootstrap  
  user_data = file("${path.module}/files/jenkins.sh")
}
resource "aws_security_group" "allow-jenkins" {
  name        = "allow_ssh_http"
  description = "Allow ssh and http port"
  # entrar na AWS > VPC > copiar a VPC ID
  vpc_id = "vpc-03c45becab303a4fc"

  ingress = [
    {
      description      = "Allow SSH"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      self             = null
      prefix_list_ids  = []
      security_groups  = []
    },
    {
      description      = "Allow Http jenkins"
      from_port        = 8080
      to_port          = 8080
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      self             = null
      prefix_list_ids  = []
      security_groups  = []
    }
  ]
  egress = [
    {
      description      = "Allow all"
      from_port        = 0
      to_port          = 0
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      self             = null
      prefix_list_ids  = []
      security_groups  = []
    }
  ]
  tags = {
    Name = "allow_ssh_http"
  }
}
resource "aws_network_interface_sg_attachment" "jenkins-sg" {
  security_group_id    = aws_security_group.allow-jenkins.id
  network_interface_id = aws_instance.jenkins-ec2.primary_network_interface_id
}
output "jenkinshost" {
  value = aws_instance.jenkins-ec2.public_ip
}