variable "vpc_cidr" {
  description = "CIDR block for application VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "resource_name_tag_perfix" {
  description = "Prefix for resources' name tag. Ex) skills -> skills-vpc"
  type        = string
  default     = "skills"
}
