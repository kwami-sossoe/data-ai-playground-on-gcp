module "vpc" {
  source     = "git::https://github.com/kwami-sossoe/cloud-foundation-fabric-modules.git//net-vpc?ref=master"
  count      = local.use_shared_vpc ? 0 : 1
  project_id = module.project.project_id
  name       = "${var.prefix}-vpc"
  subnets = [
    {
      ip_cidr_range = "10.0.0.0/20"
      name          = "${var.prefix}-subnet"
      region        = var.region
    }
  ]
}

module "vpc-firewall" {
  source     = "git::https://github.com/kwami-sossoe/cloud-foundation-fabric-modules.git//net-vpc-firewall?ref=master"
  count      = local.use_shared_vpc ? 0 : 1
  project_id = module.project.project_id
  network    = module.vpc[0].name
  default_rules_config = {
    admin_ranges = ["10.0.0.0/20"]
  }
  ingress_rules = {
    #TODO Remove and rely on 'ssh' tag once terraform-provider-google/issues/9273 is fixed
    ("${var.prefix}-iap") = {
      description   = "Enable SSH from IAP on Notebooks."
      source_ranges = ["35.235.240.0/20"]
      targets       = ["notebook-instance"]
      rules         = [{ protocol = "tcp", ports = [22] }]
    }
  }
}

module "cloudnat" {
  source         = "git::https://github.com/kwami-sossoe/cloud-foundation-fabric-modules.git//net-cloudnat?ref=master"
  count          = local.use_shared_vpc ? 0 : 1
  project_id     = module.project.project_id
  name           = "${var.prefix}-default"
  region         = var.region
  router_network = module.vpc[0].name
}

resource "google_project_iam_member" "shared_vpc" {
  count   = local.use_shared_vpc ? 1 : 0
  project = var.vpc_config.host_project
  role    = "roles/compute.networkUser"
  member  = module.project.service_agents.notebooks.iam_email
}
