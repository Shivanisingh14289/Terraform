output "arn" {
  description = "Full ARN of the repository."
  value       = aws_ecr_repository.ecr_repo.*.arn
}

output "url" {
  description = "The URL of the repository (in the form aws_account_id.dkr.ecr.region.amazonaws.com/repositoryName )"
  value       = aws_ecr_repository.ecr_repo.*.repository_url
}

output "repository_name" {
  value = aws_ecr_repository.ecr_repo.*.name
}

output "registry_id" {
  value = aws_ecr_repository.ecr_repo.*.registry_id
}