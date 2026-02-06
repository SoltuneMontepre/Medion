variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "repositories" {
  description = "Map of ECR repositories to create"
  type = map(object({
    image_tag_mutability  = optional(string, "MUTABLE")
    scan_on_push          = optional(bool, true)
    encryption_type       = optional(string, "AES256")
    lifecycle_policy_keep = optional(number, 3)
    lifecycle_expire_days = optional(number, 7)
  }))
  default = {}
}
