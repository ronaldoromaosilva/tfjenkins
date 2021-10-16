
output "jenkins-ec2" {
    value = aws_instance.jenkins-ec2.public_ip
}