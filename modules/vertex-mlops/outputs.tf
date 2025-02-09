locals {
  docker_split = try(split("/", module.artifact_registry.id), null)
  docker_repo  = try("${local.docker_split[3]}-docker.pkg.dev/${local.docker_split[1]}/${local.docker_split[5]}", null)
  gh_config = {
    WORKLOAD_ID_PROVIDER = try(google_iam_workload_identity_pool_provider.github_provider[0].name, null)
    SERVICE_ACCOUNT      = try(module.service-account-github.email, null)
    PROJECT_ID           = module.project.project_id
    DOCKER_REPO          = local.docker_repo
    SA_MLOPS             = module.service-account-mlops.email
    SUBNETWORK           = local.subnet
  }
}

output "github" {
  description = "Github Configuration."
  value       = local.gh_config
}

output "notebook" {
  description = "Vertex AI notebooks ids."
  value = merge(
    { for k, v in resource.google_notebooks_runtime.runtime : k => v.id },
    { for k, v in resource.google_workbench_instance.playground : k => v.id }
  )
}

output "project_id" {
  description = "Project ID."
  value       = module.project.project_id
}
