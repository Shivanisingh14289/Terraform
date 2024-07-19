variable "region" {
  type    = string
  default = "us-east-1"
}

variable "ecr_name" {
  type = list(string)
  description = "A prefix used for naming resources."
  default     = [""]
}

variable "max_images_retained" {
  description = "The max number of images to keep in the repository before expiring the oldest"
  default     = 15
}

variable "scan_on_push" {
  default     = false
  type        = bool
  description = "Whether images should automatically be scanned on push or not."
}

variable "image_tag_mutability" {
  default     = "MUTABLE"
  type        = string
  description = "Whether images are allowed to overwrite existing tags."
}
