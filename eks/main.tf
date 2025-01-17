resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  enabled_cluster_log_types = var.enabled_cluster_log_types
  role_arn = aws_iam_role.cluster_role.arn
  version  = var.eks_cluster_version
  tags = merge(
    {
      Name = format("%s-cluster", var.cluster_name)
    },
    {
      "Provisioner" = "Terraform"
    },
    var.tags
  )
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKSServicePolicy,
  ]

  vpc_config {
    subnet_ids = var.subnets
    
    endpoint_private_access = var.endpoint_private
    endpoint_public_access = var.endpoint_public
  }
}



resource "aws_iam_role" "cluster_role" {
  name = var.cluster_name

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
  tags = merge(
    {
      Name = format("%s-cluster_iam_role", var.cluster_name)
    },
    {
      "Provisioner" = "Terraform"
    },
    var.tags
  )
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.cluster_role.name
}

resource "aws_iam_role" "node_group_role" {
  name = var.eks_node_group_name

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
  tags = merge(
    {
      Name = format("%s-node_group_iam_role", var.eks_node_group_name)
    },
    {
      "Provisioner" = "Terraform"
    },
    var.tags
  )
}

resource "aws_iam_role_policy_attachment" "node-AmazonEC2FullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  role       = aws_iam_role.node_group_role.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group_role.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group_role.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group_role.name
}

resource "aws_ec2_tag" "add_tags_into_subnet" {
  count       = length(var.subnets)
  resource_id = var.subnets[count.index]
  key         = "kubernetes.io/cluster/${var.cluster_name}"
  value       = "shared"
}

resource "aws_security_group_rule" "cluster_private_access" {
  count       = var.cluster_endpoint_whitelist ? 1 : 0
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = var.cluster_endpoint_access_cidrs

  security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}


resource "aws_eks_node_group" "node_groups" {
  for_each     = var.create_node_group ? var.node_groups : {}
  cluster_name = aws_eks_cluster.eks_cluster.id
  tags = merge(
    {
      Name = format("%s-node_group", substr(each.key, 0, 12))
    },
    {
      "Provisioner" = "Terraform"
    },
    each.value.tags
  )
  node_group_name = substr(each.key, 0, 12)
  node_role_arn   = aws_iam_role.node_group_role.arn
  subnet_ids      = each.value.subnets
  instance_types  = each.value.instance_type
  disk_size       = each.value.disk_size
  labels          = each.value.labels
  capacity_type   = each.value.capacity_type
  force_update_version = var.force_update_version
  ami_type       = each.value.ami_type

  scaling_config {
    desired_size = each.value.desired_capacity
    max_size     = each.value.max_capacity
    min_size     = each.value.min_capacity
  }

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
    ignore_changes        = [scaling_config.0.desired_size]
  }

  remote_access {
    ec2_ssh_key               = each.value.ssh_key
    source_security_group_ids = concat(each.value.security_group_ids)
  }
}