# Deploy certbot configuration for project domains
##################################################

module "deploy-hugo-website-cert-domains" {
  source = "../../ryo-ingress-proxy/module-deployment/modules/deploy-cert-domains"

  certificate_domains = {
    domain_1 = {domain = local.project_domain_name, admin_email = local.project_admin_email},
    domain_2 = {domain = local.project_hooks_domain_name, admin_email = local.project_admin_email}
  }
}