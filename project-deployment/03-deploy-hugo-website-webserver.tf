# Deploy Hugo website webserver
###############################

resource "lxd_container" "hugo-website-webserver" {

  depends_on = [ module.deploy-hugo-website-cert-domains ]

  remote     = var.host_id
  name       = join("-", [ local.project_id, "webserver" ])
  image      = join("-", [ local.project_id, "hugo-website-webserver", var.image_version ])
  profiles   = ["default"]
  
  config = { 
    "security.privileged": "false"
    "user.user-data" = file("cloud-init/cloud-init-basic.yml")
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
      path     = "/var/www/site"
      readonly = "true"
      shift    = "true"
    }
  }
}
