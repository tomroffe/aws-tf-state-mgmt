provider "aws" {
  region = "eu-west-1"
  version = "~> 2.46.0"
}

variable "name" {
  type = string
  default = "herkules"
}

variable "environment" {
  type = string
  default = "shared"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.name}-${var.environment}-tfstate"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "${var.name}-${var.environment}-tflock"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  server_side_encryption {
    enabled = true
  }

  attribute {
    name = "LockID"
    type = "S"
  }
}

output "terraform_state_bucket" {
  value = aws_s3_bucket.terraform_state.id
}

output "terraform_state_locking_table" {
  value = aws_dynamodb_table.terraform_state_lock.id
}
