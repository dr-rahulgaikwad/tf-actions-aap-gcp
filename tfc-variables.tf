# Variables for HCP Terraform Setup

variable "tfc_oauth_token_id" {
  description = "HCP Terraform OAuth token ID for VCS connection"
  type        = string
  sensitive   = true
}

variable "tfc_organization" {
  description = "HCP Terraform organization name"
  type        = string
  default     = "rahul-tfc"
}

variable "github_repo" {
  description = "GitHub repository identifier (org/repo)"
  type        = string
  default     = "your-github-org/tf-actions-aap-gcp"
}
