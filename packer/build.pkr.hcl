source "amazon-ebs" "nginx-server-packer" {
  ami_name                    = "nginx-dev-{{timestamp}}"
  ami_description             = "AWS Instance Image Created by Packer on {{timestamp}}"
  instance_type               = "c6g.medium"
  region                      = "ap-south-1"
  security_group_id           = "sg-064ad8064cf203657"
  tags = {
    Release       = "NGINX-Packer"
    Base_AMI_Name = "{{ .SourceAMIName }}"
    Extra         = "{{ .SourceAMITags.TagName }}"
  }


  source_ami_filter {
    filters = {
      name                = "nginx-latest-base-2"
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
}