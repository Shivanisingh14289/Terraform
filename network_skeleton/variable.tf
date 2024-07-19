
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
  default     = "New-Hcl-Uat"
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
      az         = "ap-south-1a"
    },
    {
      name       = "New-Demo-SubnetPublicAPSOUTH1B"
      cidr_block = "10.145.64.0/19"
      az         = "ap-south-1b"
    },
    {
      name       = "New-Demo-SubnetPublicAPSOUTH1C"
      cidr_block = "10.145.0.0/19"
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
      az         = "ap-south-1a"
    },
    {
      name       = "New-Demo-SubnetPrivateAPSOUTHOperator1A"
      cidr_block = "10.145.192.0/24"
      az         = "ap-south-1a"
    },
    {
      name       = "New-Demo-SubnetPrivateAPSOUTH1B"
      cidr_block = "10.145.160.0/19"
       az         = "ap-south-1b"
    },
    {
      name       = "New-Demo-SubnetPrivateAPSOUTH1C"
      cidr_block = "10.145.96.0/19"
      az         = "ap-south-1c"
    }
  ]
}
variable "private_route_tables" {
  description = "A list of private route table configurations"
  type        = list(string)
  default     = ["New-Demo-PrivateRouteTableAPSOUTH1A", "New-Demo-PrivateRouteTableAPSOUTHOperator1A", "New-Demo-PrivateRouteTableAPSOUTH1B", "New-Demo-PrivateRouteTableAPSOUTH1C"]
}



