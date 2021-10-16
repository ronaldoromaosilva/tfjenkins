module "jenkinsapp" {
  # module
  source = "./modules/jenkins"

  # Amazon VPC
  vpc_id = "YOUR_VPC_ID"

  # Amazon subnet
  subnet_cidr = "YOUR_SUBNET_IP_RANGE"

  # SSH Key
  ssh_key = "public_key"

  # jenkinsapp
  app_name = "jenkins"

  # App
  app_instance = "t2.small"
  
  # tags
  app_tags = {
    env      = "prod"
    project  = "Jenkins"
    customer = "Valdir Bitar"
    curso    = "CL0506"
  

}
resource "null_resource" "Jenkins" {
  triggers = {
    instance = module.jenkinsapp.jenkins-ec2
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${path.module}/modules/jenkins/files/jenkins.pem")
    host        = module.jenkinsapp.jenkins-ec2
  }
  provisioner "remote-exec" {
    inline = [
      "sleep 300",
      "sudo cat /var/lib/jenkins/secrets/initialAdminPassword",
    ]
  }
}
output "jenkins-ip" {
  value = module.jenkinsapp.jenkins-ec2
}