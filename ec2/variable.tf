variable "instance_count" {
  type        = number
  description = "Number of instances to create"
}

variable "instance_type" {
  type        = list(string)
  description = "Instance type"
  default = [ "r5.large","r5.xlarge" ]
}

variable "ami_id" {
  type        = list(string)
  description = "AMI ID"
  default = [ "ami-0c1a7f89451184c8b","ami-0f5ee92e2d63afc18" ]
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID"
}

variable "name" {
  type = list(string)
  default = ["New-Demo-Operator", "New-Demo-Devops-Server"]
}