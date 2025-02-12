resource "google_iam_workload_identity_pool" "github_pool" {
  count                     = var.identity_pool_claims == null ? 0 : 1
  project                   = module.project.project_id
  workload_identity_pool_id = "gh-pool"
  display_name              = "Github Actions Identity Pool"
  description               = "Identity pool for Github Actions"
}

resource "google_iam_workload_identity_pool_provider" "github_provider" {
  count                              = var.identity_pool_claims == null ? 0 : 1
  project                            = module.project.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool[0].workload_identity_pool_id
  workload_identity_pool_provider_id = "gh-provider"
  display_name                       = "Github Actions provider"
  description                        = "OIDC provider for Github Actions"
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
  }
  attribute_condition = var.identity_pool_assertions
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

module "artifact_registry" {
  source     = "git::https://github.com/kwami-sossoe/cloud-foundation-fabric-modules.git//artifact-registry?ref=master"
  name       = "docker-repo"
  project_id = module.project.project_id
  location   = var.region
  format     = { docker = { standard = {} } }
}

module "service-account-github" {
  source     = "git::https://github.com/kwami-sossoe/cloud-foundation-fabric-modules.git//iam-service-account?ref=master"
  name       = "${var.prefix}-sa-github"
  project_id = module.project.project_id
  iam        = var.identity_pool_claims == null ? {} : { "roles/iam.workloadIdentityUser" = ["principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool[0].name}/${var.identity_pool_claims}"] }
}

# NOTE: Secret manager module at the moment does not support CMEK
module "secret-manager" {
  project_id = module.project.project_id
  source     = "git::https://github.com/kwami-sossoe/cloud-foundation-fabric-modules.git//secret-manager?ref=master"
  secrets = {
    github-key = {
      locations = [var.region]
      keys = {
        "${var.region}" = var.service_encryption_keys.secretmanager
      }
    }
  }
  iam = {
    github-key = {
      "roles/secretmanager.secretAccessor" = [
        module.project.service_agents.cloudbuild.iam_email,
        module.service-account-mlops.iam_email
      ]
    }
  }
}
