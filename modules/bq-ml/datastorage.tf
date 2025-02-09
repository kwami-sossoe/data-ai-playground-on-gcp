module "bucket" {
  source         = "../cloud-foundataion-fabric-modules/gcs"
  project_id     = module.project.project_id
  prefix         = var.prefix
  location       = var.location
  name           = "data"
  encryption_key = var.service_encryption_keys.storage
  force_destroy  = !var.deletion_protection
}

module "dataset" {
  source         = "../cloud-foundataion-fabric-modules/bigquery-dataset"
  project_id     = module.project.project_id
  id             = "${replace(var.prefix, "-", "_")}_data"
  encryption_key = var.service_encryption_keys.bq
  location       = var.location
}
