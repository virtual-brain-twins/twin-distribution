packer {
  required_plugins {
    virtualbox = {
      version = "~> 1"
      source  = "github.com/hashicorp/virtualbox"
    }
  }
}

variable "password" {
  type    = string
  default = "vagrant"
}

source "virtualbox-iso" "ubuntu" {
  guest_os_type    = "Ubuntu_64"
  iso_urls         = [
    "iso/ubuntu-22.04.5-live-server-amd64.iso",
    "https://releases.ubuntu.com/22.04/ubuntu-22.04.5-live-server-amd64.iso"
  ]
  iso_checksum     = "9bc6028870aef3f74f4e16b900008179e78b130e6b0b9a140635434a46aa98b0"
  
  ssh_username     = "vagrant"
  ssh_password     = var.password
  ssh_timeout      = "20m"            # Wait up to 20 minutes for SSH (extended for autoinstall)
  shutdown_command = "echo '${var.password}' | sudo -S shutdown -P now"

  cpus             = 4
  memory           = 4096
  disk_size        = 61440

  http_directory   = "http"

  boot_wait = "3s"
  boot_command = [
    "<wait3s>c<wait3s>",
    "linux /casper/vmlinuz --- ",
    "ip=::::::dhcp::: ",             # Configure DHCP for network (for autoinstall)
    "autoinstall 'ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/'",
    "<enter><wait>",
    "initrd /casper/initrd",
    "<enter><wait>",
    "boot",
    "<enter>"
  ]

  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--nic1", "nat"],
    ["modifyvm", "{{.Name}}", "--firmware", "bios"]
  ]
  keep_registered = true             # Do not unregister VM on completion (keep for debugging on failure)
}

build {
  sources = ["source.virtualbox-iso.ubuntu"]

  provisioner "shell" {
    script           = "setup.sh"
    execute_command  = "echo '${var.password}' | sudo -S bash '{{.Path}}'"
  }

  post-processor "vagrant" {
    output = "ubuntu.box"
  }
}
