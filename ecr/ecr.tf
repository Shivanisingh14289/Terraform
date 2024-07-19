resource "aws_ecr_repository" "ecr_repo" {
  count = length(var.ecr_name)
  name = element(var.ecr_name, count.index)
  image_tag_mutability = var.image_tag_mutability
  image_scanning_configuration {
  scan_on_push = var.scan_on_push
  }
}

resource "aws_ecr_repository_policy" "repo_policy" {
  count = length(var.ecr_name)
  repository = element(aws_ecr_repository.ecr_repo.*.id, count.index)

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "1",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:DescribeRepositories",
                "ecr:GetRepositoryPolicy",
                "ecr:ListImages",
                "ecr:DeleteRepository",
                "ecr:BatchDeleteImage",
                "ecr:SetRepositoryPolicy",
                "ecr:DeleteRepositoryPolicy"
            ]
        }
    ]
}
EOF
}
resource "aws_ecr_lifecycle_policy" "keep_last_N" {
  count = length(var.ecr_name)
  repository = element(aws_ecr_repository.ecr_repo.*.id, count.index)

  policy = <<EOF
  {
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last ${var.max_images_retained} images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": ${var.max_images_retained}
            },
            "action": {
                "type": "expire"
            }
        }
    ]
  }
EOF
}
