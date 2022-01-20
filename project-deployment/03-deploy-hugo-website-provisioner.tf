# Deploy Hugo website provisioner
#################################

resource "lxd_container" "hugo-website-provisioner" {
  remote     = var.host_id
  name       = "hugo-website-provisioner"
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

# Deploy certbot configuration for hooks domain
###############################################

module "deploy-hugo-website-provisioner-cert-domains" {
  source = "../../ryo-ingress-proxy/module-deployment/modules/deploy-cert-domains"

  certificate_domains = {
    domain_1 = {domain = local.project_hooks_domain_name, admin_email = local.project_admin_email}
  }
}


# Deploy Ingress Proxy configuration
####################################

module "deploy-hugo-website-provisioner-ingress-proxy-backend-service" {
  source = "../../ryo-ingress-proxy/module-deployment/modules/deploy-ingress-proxy-backend-services"
  non_ssl_backend_services = [ "hugo-website-provisioner" ]
}

module "deploy-hugo-website-provisioner-ingress-proxy-acl-configuration" {
  source = "../../ryo-ingress-proxy/module-deployment/modules/deploy-ingress-proxy-configuration"

  depends_on = [ module.deploy-hugo-website-provisioner-ingress-proxy-backend-service ]

  ingress-proxy_host_only_acls = {
    domain-hooks = {host = local.project_hooks_domain_name}
  }
}

module "deploy-hugo-website-provisioner-ingress-proxy-backend-configuration" {
  source = "../../ryo-ingress-proxy/module-deployment/modules/deploy-ingress-proxy-configuration"

  depends_on = [ module.deploy-hugo-website-provisioner-ingress-proxy-backend-service ]

  ingress-proxy_acl_use-backends = {
    domain-hooks = {backend_service = "hugo-website-provisioner"}
  }
}
