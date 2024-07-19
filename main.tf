provider "aws" {
  profile = "default"
  region  = "ap-south-1"
}


module "network_skeleton" {
  source               = "./network_skeleton"
  region               = var.region
  stack_name           = var.stack_name
  vpc_cidr_block       = var.vpc_cidr_block
  key_name             = var.key_name
  public_subnets       = var.public_subnets
  private_subnets      = var.private_subnets
  private_route_tables = var.private_route_tables
}

module "ecr" {
  source               = "./ecr"
  region               = var.region
  ecr_name             = var.ecr_name
  max_images_retained  = 15
  scan_on_push         = true
  image_tag_mutability = "MUTABLE"
}



locals {
  common_tags        = { ENV : "New-Uat-Demo", OWNER : "HCL-HC" }
  worker_group1_tags = { "name" : "worker01", Name : "New-Uat-EKS-Node" }
  worker_group2_tags = { "name" : "worker02", Name : "New-Uat-EKS-Node" }
}
resource "aws_security_group" "securitygroup" {
  name   = "New-Uat-Demo-SG"
  vpc_id = module.network_skeleton.vpc_id
  tags   = local.common_tags
  dynamic "ingress" {
    for_each = var.sgingress

    content {
      description     = ingress.value.description
      from_port       = ingress.value.fromport
      to_port         = ingress.value.toport
      protocol        = ingress.value.protocol
      cidr_blocks     = ingress.value.cidrblocks
      self            = ingress.value.self
      security_groups = ingress.value.security_groups
    }
  }

  dynamic "egress" {
    for_each = var.sgegress

    content {
      description     = egress.value.description
      from_port       = egress.value.fromport
      to_port         = egress.value.toport
      protocol        = egress.value.protocol
      cidr_blocks     = egress.value.cidrblocks
      self            = egress.value.self
      security_groups = egress.value.security_groups
    }
  }
}


module "EKS" {

  source              = "./eks"
  cluster_name        = var.cluster_name
  eks_cluster_version = "1.29"
  subnets             = concat([module.network_skeleton.private_subnet_ids[0]], [module.network_skeleton.private_subnet_ids[2]], [module.network_skeleton.private_subnet_ids[3]], module.network_skeleton.public_subnet_ids)
  tags                = local.common_tags
  kubeconfig_name     = "kubeconfig"
  config_output_path  = "kubeconfig"
  eks_node_group_name = var.eks_node_group_name
  region              = var.region
  create_node_group   = true
  endpoint_private    = false
  endpoint_public     = true
  vpc_id              = module.network_skeleton.vpc_id
  node_groups = {
    "worker1" = {
      subnets = flatten([module.network_skeleton.private_subnet_ids[0], module.network_skeleton.private_subnet_ids[2], module.network_skeleton.private_subnet_ids[3], module.network_skeleton.public_subnet_ids])
      ssh_key = var.ssh_key
      #      ami_type           = "ami-0f23aedb88a10adc5"
      ami_type           = "AL2_x86_64"
      security_group_ids = [aws_security_group.securitygroup.id]
      instance_type      = var.instance_type
      desired_capacity   = var.scale_desired_size
      disk_size          = var.disk_size
      max_capacity       = var.scale_max_size
      min_capacity       = var.scale_min_size
      capacity_type      = "SPOT"
      tags               = merge(local.common_tags, local.worker_group1_tags)
      labels             = { "node_group" : "worker1" }
    }
    "worker2" = {
      subnets = flatten([module.network_skeleton.private_subnet_ids[0], module.network_skeleton.private_subnet_ids[2], module.network_skeleton.private_subnet_ids[3], module.network_skeleton.public_subnet_ids])
      ssh_key = var.ssh_key
      #       ami_type           = "ami-0f23aedb88a10adc5"  
      ami_type           = "AL2_x86_64"
      security_group_ids = [aws_security_group.securitygroup.id]
      instance_type      = var.instance_type_2
      desired_capacity   = var.scale_desired_size_worker2
      disk_size          = var.disk_size
      max_capacity       = var.scale_max_size
      min_capacity       = var.scale_min_size_worker2
      capacity_type      = "SPOT"
      tags               = merge(local.common_tags, local.worker_group2_tags)
      labels             = { "node_group" : "worker2" }
    }
  }

}

module "EC2" {
  source = "./ec2/"
  vpc_id = module.network_skeleton.vpc_id
  instance_count = 2
  subnet_id = module.network_skeleton.public_subnet_ids[1]
  name = var.instance_name
}


module "auto_scaler" {
  source       = "./autoscaler/"
  cluster_name = var.cluster_name
  region       = var.region

}
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}
data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}
data "aws_iam_openid_connect_provider" "oidc_provider" {
  url = data.aws_eks_cluster.cluster.identity.0.oidc.0.issuer
}
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  }
}
module "alb_controller" {
  source                           = "./alb_controller"
  cluster_name                     = var.cluster_name
  cluster_identity_oidc_issuer     = data.aws_eks_cluster.cluster.identity.0.oidc.0.issuer
  cluster_identity_oidc_issuer_arn = data.aws_iam_openid_connect_provider.oidc_provider.arn
  region                           = var.region
}