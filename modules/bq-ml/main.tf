locals {
  shared_vpc_project = try(var.vpc_config.host_project, null)
  subnet = (
    local.use_shared_vpc
    ? var.vpc_config.subnet_self_link
    : values(module.vpc[0].subnet_self_links)[0]
  )
  use_shared_vpc = var.vpc_config != null
  vpc = (
    local.use_shared_vpc
    ? var.vpc_config.network_self_link
    : module.vpc[0].self_link
  )
}

module "project" {
  source          = "git::https://github.com/kwami-sossoe/cloud-foundation-fabric-modules.git//project?ref=master"
  name            = var.project_id
  parent          = try(var.project_create.parent, null)
  billing_account = try(var.project_create.billing_account_id, null)
  project_create  = var.project_create != null
  prefix          = var.project_create == null ? null : var.prefix
  services = [
    "aiplatform.googleapis.com",
    "bigquery.googleapis.com",
    "bigquerystorage.googleapis.com",
    "bigqueryreservation.googleapis.com",
    "compute.googleapis.com",
    "ml.googleapis.com",
    "notebooks.googleapis.com",
    "servicenetworking.googleapis.com",
    "stackdriver.googleapis.com",
    "storage.googleapis.com",
    "storage-component.googleapis.com"
  ]
  shared_vpc_service_config = local.shared_vpc_project == null ? null : {
    attach       = true
    host_project = local.shared_vpc_project
  }
  service_encryption_key_ids = {
    "aiplatform.googleapis.com" = compact([var.service_encryption_keys.compute])
    "compute.googleapis.com"    = compact([var.service_encryption_keys.compute])
    "bigquery.googleapis.com"   = compact([var.service_encryption_keys.bq])
    "storage.googleapis.com"    = compact([var.service_encryption_keys.storage])
  }
  service_config = {
    disable_on_destroy = false, disable_dependent_services = false
  }
}
