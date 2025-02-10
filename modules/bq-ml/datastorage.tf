module "bucket" {
  source         = "git::https://github.com/kwami-sossoe/cloud-foundation-fabric-modules.git//gcs?ref=master"
  project_id     = module.project.project_id
  prefix         = var.prefix
  location       = var.location
  name           = "data"
  encryption_key = var.service_encryption_keys.storage
  force_destroy  = !var.deletion_protection
}

module "dataset" {
  source         = "git::https://github.com/kwami-sossoe/cloud-foundation-fabric-modules.git//bigquery-dataset?ref=master"
  project_id     = module.project.project_id
  id             = "${replace(var.prefix, "-", "_")}_data"
  encryption_key = var.service_encryption_keys.bq
  location       = var.location
}
