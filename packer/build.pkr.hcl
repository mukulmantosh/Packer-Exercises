variable "ami_name" {
  type        = string
  description = "The name of the newly created AMI"
  default     = "fastapi-nginx-ami-{{timestamp}}"
}

variable "security_group" {
  type        = string
  description = "SG specific for Packer"
  default     = "sg-064ad8064cf203657"
}

variable "tags" {
  type = map(string)
  default = {
    "Name" : "FastAPI-NGINX-AMI-{{timestamp}}"
    "Environment" : "Production"
    "OS_Version" : "Amazon Linux 2"
    "Release" : "Latest"
    "Creator" : "Packer"
  }
}
source "amazon-ebs" "nginx-server-packer" {
  ami_name          = var.ami_name
  ami_description   = "AWS Instance Image Created by Packer on {{timestamp}}"
  instance_type     = "c6g.medium"
  region            = "ap-south-1"
  security_group_id = var.security_group
  tags              = var.tags

  run_tags        = var.tags
  run_volume_tags = var.tags
  snapshot_tags   = var.tags



  source_ami_filter {
    filters = {
      name                = "FastAPI_Base_Image"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }

    most_recent = true
    owners      = ["self"]
  }
  ssh_username = "ec2-user"



}



build {
  sources = [
    "source.amazon-ebs.nginx-server-packer"
  ]

  provisioner "shell" {
    inline = [
      "sudo yum update -y",
    ]
  }

  provisioner "shell" {
    script       = "./scripts/build.sh"
    pause_before = "10s"
    timeout      = "300s"
  }

  provisioner "file" {
    source      = "./scripts/fastapi.conf"
    destination = "/tmp/fastapi.conf"
  }


  provisioner "shell" {
    inline = ["sudo mv /tmp/fastapi.conf /etc/nginx/conf.d/fastapi.conf"]
  }

  error-cleanup-provisioner "shell" {
    inline = ["echo 'update provisioner failed' > packer_log.txt"]
  }

}