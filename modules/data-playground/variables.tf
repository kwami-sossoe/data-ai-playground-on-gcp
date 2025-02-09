variable "deletion_protection" {
  description = "Prevent Terraform from destroying data storage resources (storage buckets, GKE clusters, CloudSQL instances) in this blueprint. When this field is set in Terraform state, a terraform destroy or terraform apply that would delete data storage resources will fail."
  type        = bool
  default     = false
  nullable    = false
}

variable "location" {
  description = "The location where resources will be deployed."
  type        = string
  default     = "EU"
}

variable "network_config" {
  description = "Shared VPC network configurations to use. If null networks will be created in projects with preconfigured values."
  type = object({
    host_project      = string
    network_self_link = string
    subnet_self_link  = string
  })
  default = null
}

variable "prefix" {
  description = "Prefix used for resource names."
  type        = string
  validation {
    condition     = var.prefix != ""
    error_message = "Prefix cannot be empty."
  }
}

variable "project_create" {
  description = "Provide values if project creation is needed, uses existing project if null. Parent format:  folders/folder_id or organizations/org_id."
  type = object({
    billing_account_id = string
    parent             = string
  })
  default = null
}

variable "project_id" {
  description = "Project id, references existing project if `project_create` is null."
  type        = string
}

variable "region" {
  description = "The region where resources will be deployed."
  type        = string
  default     = "europe-west1"
}

variable "service_encryption_keys" { # service encryption key
  description = "Cloud KMS to use to encrypt different services. Key location should match service region."
  type = object({
    bq      = optional(string)
    compute = optional(string)
    storage = optional(string)
  })
  default  = {}
  nullable = false
}
