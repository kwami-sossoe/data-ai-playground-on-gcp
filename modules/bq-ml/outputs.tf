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

output "service-account-vertex" {
  description = "Service account to be used for Vertex AI pipelines."
  value       = module.service-account-vertex.email
}

output "vertex-ai-metadata-store" {
  description = "Vertex AI Metadata Store ID."
  value       = google_vertex_ai_metadata_store.store.id
}

output "vpc" {
  description = "VPC Network."
  value       = local.vpc
}
