
variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.145.0.0/16"
}

variable "stack_name" {
  description = "The name of the  stack"
  type        = string
  default     = "New-Uat-Demo"
}
variable "key_name" {
  type    = string
  default = "hcl_uat"
}

variable "public_subnets" {
  description = "A list of subnet configurations"
  type = list(object({
    name       = string
    cidr_block = string
    az         = string
  }))
  default = [
    {
      name       = "New-Demo-SubnetPublicAPSOUTH1A"
      cidr_block = "10.145.32.0/19"
#      az         = "us-east-1a"
       az         = "ap-south-1a"
    },
    {
      name       = "New-Demo-SubnetPublicAPSOUTH1B"
      cidr_block = "10.145.64.0/19"
#      az         = "us-east-1b"
       az         = "ap-south-1b"
    },
    {
      name       = "New-Demo-SubnetPublicAPSOUTH1C"
      cidr_block = "10.145.0.0/19"
#      az         = "us-east-1c"
       az         = "ap-south-1c"
    }
  ]
}

variable "private_subnets" {
  description = "A list of private subnet configurations"
  type = list(object({
    name       = string
    cidr_block = string
    az         = string
  }))
  default = [
    {
      name       = "New-Demo-SubnetPrivateAPSOUTH1A"
      cidr_block = "10.145.128.0/19"
#      az         = "us-east-1a"
       az         = "ap-south-1a"
    },
    {
      name       = "New-Demo-SubnetPrivateAPSOUTHOperator1A"
      cidr_block = "10.145.192.0/24"
#      az         = "us-east-1a"
       az         = "ap-south-1a"
    },
    {
      name       = "New-Demo-SubnetPrivateAPSOUTH1B"
      cidr_block = "10.145.160.0/19"
#      az         = "us-east-1b"
       az         = "ap-south-1b"
    },
    {
      name       = "New-Demo-SubnetPrivateAPSOUTH1C"
      cidr_block = "10.145.96.0/19"
#      az         = "us-east-1c"
       az         = "ap-south-1c"
    }
  ]
}
variable "private_route_tables" {
  description = "A list of private route table configurations"
  type        = list(string)
  default     = ["New-Demo-PrivateRouteTableAPSOUTH1A", "New-Demo-PrivateRouteTableAPSOUTHOperator1A", "New-Demo-PrivateRouteTableAPSOUTH1B", "New-Demo-PrivateRouteTableAPSOUTH1C"]
}

## ECR 

variable "ecr_name" {
  type        = list(string)
  description = "A prefix used for naming resources."
  default     = [""]
}


variable "cluster_name" {
  description = "EKS cluster name"
  default     = "New-Uat-demo"
  type        = string
}


variable "eks_node_group_name" {
  description = "Node group name for EKS"
  default     = "New-Uat-Demo-Node-Group"
  type        = string
}
variable "ssh_key" {
  type    = string
  default = "hcl_uat"
}

variable "instance_type" {
  type    = list(string)
  default = ["t3.xlarge"]
}
variable "instance_type_2" {
  type    = list(string)
  default = ["c5.xlarge"]
}
variable "disk_size" {
  description = "Disk size of workers"
  type        = number
  default     = 8
}

variable "scale_min_size" {
  description = "Minimum count of workers"
  type        = number
  default     = 1
}
variable "scale_min_size_worker2" {
  description = "Minimum count of workers"
  type        = number
  default     = 1
}
variable "scale_max_size" {
  description = "Maximum count of workers"
  type        = number
  default     = 2
}

variable "scale_desired_size" {
  description = "Desired count of workers"
  type        = number
  default     = 1
}
variable "scale_desired_size_worker2" {
  description = "Desired count of workers"
  type        = number
  default     = 1
}

variable "sgingress" {

  default = [
    {
      description     = ""
      fromport        = 0
      toport          = 0
      protocol        = -1
      cidrblocks      = []
      self            = true
      security_groups = []
    }
  ]
}

variable "sgegress" {

  default = [
    {
      description     = ""
      fromport        = 0
      toport          = 0
      protocol        = -1
      cidrblocks      = ["0.0.0.0/0"]
      self            = false
      security_groups = []
    }
  ]
}

variable "instance_name" {
  type = list(string)
  default = ["New-Demo-Operator", "New-Demo-Devops-Server"]
}
