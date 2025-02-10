resource "google_vertex_ai_metadata_store" "store" {
  provider    = google-beta
  project     = module.project.project_id
  name        = "default"
  description = "Vertex Ai Metadata Store"
  region      = var.region
  dynamic "encryption_spec" {
    for_each = var.service_encryption_keys.aiplatform == null ? [] : [""]
    content {
      kms_key_name = var.service_encryption_keys.aiplatform
    }
  }
  # `state` value will be decided automatically based on the result of the configuration
  lifecycle {
    ignore_changes = [state]
  }
}

module "service-account-notebook" {
  source     = "git::https://github.com/kwami-sossoe/cloud-foundation-fabric-modules.git//iam-service-account?ref=master"
  project_id = module.project.project_id
  name       = "notebook-sa"
  iam_project_roles = {
    (module.project.project_id) = [
      "roles/bigquery.admin",
      "roles/bigquery.jobUser",
      "roles/bigquery.dataEditor",
      "roles/bigquery.user",
      "roles/dialogflow.client",
      "roles/storage.admin",
      "roles/aiplatform.user",
      "roles/iam.serviceAccountUser"
    ]
  }
}

module "service-account-vertex" {
  source     = "git::https://github.com/kwami-sossoe/cloud-foundation-fabric-modules.git//iam-service-account?ref=master"
  project_id = module.project.project_id
  name       = "vertex-sa"
  iam_project_roles = {
    (module.project.project_id) = [
      "roles/bigquery.admin",
      "roles/bigquery.jobUser",
      "roles/bigquery.dataEditor",
      "roles/bigquery.user",
      "roles/dialogflow.client",
      "roles/storage.admin",
      "roles/aiplatform.user"
    ]
  }
}

resource "google_notebooks_instance" "playground" {
  name         = "${var.prefix}-notebook"
  location     = format("%s-%s", var.region, "b")
  machine_type = "e2-medium"
  project      = module.project.project_id

  container_image {
    repository = "gcr.io/deeplearning-platform-release/base-cpu"
    tag        = "latest"
  }

  install_gpu_driver = true
  boot_disk_type     = "PD_SSD"
  boot_disk_size_gb  = 110
  disk_encryption    = var.service_encryption_keys.compute != null ? "CMEK" : null
  kms_key            = var.service_encryption_keys.compute

  no_public_ip    = true
  no_proxy_access = false

  network = local.vpc
  subnet  = local.subnet

  service_account = module.service-account-notebook.email

  # Enable Secure Boot 
  shielded_instance_config {
    enable_secure_boot = true
  }

  # Remove once terraform-provider-google/issues/9164 is fixed
  lifecycle {
    ignore_changes = [disk_encryption, kms_key]
  }

  #TODO Uncomment once terraform-provider-google/issues/9273 is fixed
  # tags = ["ssh"]
  depends_on = [
    google_project_iam_member.shared_vpc,
  ]
}
