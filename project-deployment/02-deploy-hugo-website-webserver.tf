# Deploy Hugo website webserver
###############################

resource "lxd_container" "hugo-website-webserver" {
  remote     = var.host_id
  name       = "hugo-website-webserver"
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

# Deploy certbot configuration for project domain
#################################################

module "deploy-hugo-website-webserver-cert-domains" {
  source = "../../ryo-ingress-proxy/module-deployment/modules/deploy-cert-domains"

  certificate_domains = {
    domain_1 = {domain = local.project_domain_name, admin_email = local.project_admin_email},
    domain_2 = {domain = join("", [ "www.", local.project_domain_name]), admin_email = local.project_admin_email}
  }
}


# Deploy Ingress Proxy configuration
####################################

module "deploy-hugo-website-webserver-ingress-proxy-backend-service" {
  source = "../../ryo-ingress-proxy/module-deployment/modules/deploy-ingress-proxy-backend-services"
  non_ssl_backend_services = [ "hugo-website-webserver" ]
}

module "deploy-hugo-website-webserver-ingress-proxy-acl-configuration" {
  source = "../../ryo-ingress-proxy/module-deployment/modules/deploy-ingress-proxy-configuration"

  depends_on = [ module.deploy-hugo-website-webserver-ingress-proxy-backend-service ]

  ingress-proxy_host_only_acls = {
    domain     = {host = local.project_domain_name},
    domain-www = {host = join("", [ "www.", local.project_domain_name])}
  }
}

module "deploy-hugo-website-webserver-ingress-proxy-backend-configuration" {
  source = "../../ryo-ingress-proxy/module-deployment/modules/deploy-ingress-proxy-configuration"

  depends_on = [ module.deploy-hugo-website-webserver-ingress-proxy-backend-service ]

  ingress-proxy_acl_use-backends = {
    domain     = {backend_service = "hugo-website-webserver"},
    domain-www = {backend_service = "hugo-website-webserver"}
  }
}
