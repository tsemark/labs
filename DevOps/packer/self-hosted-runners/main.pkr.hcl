packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "gh_runner_url" {
  type        = string
  default     = ""
  description = "GitHub repository URL for the runner (e.g., https://github.com/ORG/REPO). Leave empty to skip runner configuration."
  sensitive   = false
}

variable "gh_runner_token" {
  type        = string
  default     = ""
  description = "GitHub Actions runner registration token. Leave empty to skip runner configuration."
  sensitive   = true
}

source "amazon-ebs" "this" {
  ami_name      = "gh_runners_{{timestamp}}"
  instance_type = "t4g.xlarge"
  region        = "ap-east-1"
  ssh_username  = "ubuntu"
  source_ami    = "ami-0a1ff31c99777e87d"

  launch_block_device_mappings {
    device_name  = "/dev/sda1"
    volume_size  = 10
    volume_type  = "gp3"
  }

  tags = {
    "Name"       = "gh-runners-ami"
    "Created-by" = "Packer"
  }
}

build {
  sources = ["source.amazon-ebs.this"]

  provisioner "file" {
    source      = "provision.sh"
    destination = "/tmp/provision.sh"
  }
  provisioner "file" {
    source      = "actions-runner.service"
    destination = "/tmp/actions-runner.service"
  }
  provisioner "shell" {
    environment_vars = [
      "GH_RUNNER_URL=${var.gh_runner_url}",
      "GH_RUNNER_TOKEN=${var.gh_runner_token}"
    ]
    inline = [
      "chmod +x /tmp/provision.sh",
      "sudo sh -c /tmp/provision.sh"
    ]
  }
}