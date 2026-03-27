terraform {
  required_providers {
    virtualbox = {
      source  = "terra-farm/virtualbox"
      version = "0.2.2-alpha.1"
    }
  }
}

provider "virtualbox" {}

# VM1 - Gateway (publicly accessible)
resource "virtualbox_vm" "vm1_gateway" {
  name   = "vm1-gateway"
  image  = "https://app.vagrantup.com/ubuntu/boxes/focal64/versions/20230119.0.1/providers/virtualbox.box"
  cpus   = 1
  memory = "1024 mib"

  network_adapter {
    type           = "bridged"
    host_interface = "Intel(R) Wi-Fi 6 AX201 160MHz"
  }

  network_adapter {
    type           = "hostonly"
    host_interface = "VirtualBox Host-Only Ethernet Adapter"
  }
}

# VM2 - App Server (internal only)
resource "virtualbox_vm" "vm2_appserver" {
  name   = "vm2-appserver"
  image  = "https://app.vagrantup.com/ubuntu/boxes/focal64/versions/20230119.0.1/providers/virtualbox.box"
  cpus   = 1
  memory = "1024 mib"

  network_adapter {
    type           = "hostonly"
    host_interface = "VirtualBox Host-Only Ethernet Adapter"
  }
}