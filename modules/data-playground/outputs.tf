output "bucket" {
  description = "GCS Bucket URL."
  value       = module.bucket.url
}

output "dataset" {
  description = "GCS Bucket URL."
  value       = module.dataset.id
}

output "notebook" {
  description = "Vertex AI notebook details."
  value = {
    name = resource.google_notebooks_instance.playground.name
    id   = resource.google_notebooks_instance.playground.id
  }
}

output "project" {
  description = "Project id."
  value       = module.project.project_id
}

output "vpc" {
  description = "VPC Network."
  value       = local.vpc
}
