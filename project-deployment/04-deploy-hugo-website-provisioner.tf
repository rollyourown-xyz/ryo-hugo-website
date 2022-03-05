# SPDX-FileCopyrightText: 2022 Wilfred Nicoll <xyzroller@rollyourown.xyz>
# SPDX-License-Identifier: GPL-3.0-or-later

# Deploy Hugo website provisioner
#################################

resource "lxd_container" "hugo-website-provisioner" {

  depends_on = [ module.deploy-hugo-website-cert-domains ]

  remote     = var.host_id
  name       = join("-", [ local.project_id, "provisioner" ])
  image      = join("-", [ local.project_id, "hugo-website-provisioner", var.image_version ])
  profiles   = ["default"]
  
  config = { 
    "security.privileged": "false"
    "user.user-data" = file("cloud-init/cloud-init-website-provisioner.yml")
  }
  
  # Provide eth0 interface with dynamic IP address
  device {
    name = "eth0"
    type = "nic"

    properties = {
      name           = "eth0"
      network        = var.host_id
    }
  }
  
  # Mount container directory for persistent storage for grav user data
  device {
    name = "website"
    type = "disk"
    
    properties = {
      source   = join("", [ "/var/containers/", local.project_id, "/website" ])
      path     = "/var/hugo/public"
      readonly = "false"
      shift    = "true"
    }
  }
}
