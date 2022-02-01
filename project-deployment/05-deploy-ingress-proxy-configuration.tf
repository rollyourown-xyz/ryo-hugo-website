# Deploy Ingress Proxy configuration
####################################

module "deploy-hugo-website-ingress-proxy-backend-services" {
  source = "../../ryo-ingress-proxy/module-deployment/modules/deploy-ingress-proxy-backend-services"
  
  depends_on = [ lxd_container.hugo-website-webserver, lxd.container.hugo-website-provisioner ]
  
  non_ssl_backend_services = [
    join("-", [ local.project_id, "webserver" ]),
    join("-", [ local.project_id, "provisioner" ])
  ]
}

module "deploy-hugo-website-ingress-proxy-configuration" {
  source = "../../ryo-ingress-proxy/module-deployment/modules/deploy-ingress-proxy-configuration"

  depends_on = [ module.deploy-hugo-website-ingress-proxy-backend-services ]

  ingress-proxy_host_only_acls = {
    join("-", [ local.project_id, "domain" ]) = {host = local.project_domain_name},
    join("-", [ local.project_id, "domain-hooks" ]) = {host = local.project_hooks_domain_name}
  }

  ingress-proxy_acl_use-backends = {
    join("-", [ local.project_id, "domain" ]) = {backend_service = join("-", [ local.project_id, "webserver" ])},
    join("-", [ local.project_id, "domain-hooks" ]) = {backend_service = join("-", [ local.project_id, "provisioner" ])}
  }
}
