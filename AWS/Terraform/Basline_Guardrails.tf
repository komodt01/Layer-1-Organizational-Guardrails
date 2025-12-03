############################################################
# AWS – STRICT ORGANIZATIONAL GUARDRAILS (LAYER 1)
############################################################

# Deny deployments in unapproved regions
resource "aws_organizations_policy" "deny_unapproved_regions" {
  name        = "deny-unapproved-regions"
  description = "Deny access to any region not explicitly allowed."
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyNonAllowedRegions"
        Effect   = "Deny"
        Action   = "*"
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = [
              "us-east-1",
              "us-west-2"
            ]
          }
        }
      }
    ]
  })
}

# Block public bucket ACLs and policies
resource "aws_organizations_policy" "block_public_s3" {
  name = "block-public-s3"
  type = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "BlockPublicAccess"
        Effect = "Deny"
        Action = [
          "s3:PutBucketAcl",
          "s3:PutBucketPolicy"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = [
              "public-read",
              "public-read-write"
            ]
          }
        }
      }
    ]
  })
}

# Restrict EC2 instance types
resource "aws_organizations_policy" "restrict_instance_types" {
  name = "restrict-instance-types"
  type = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "RestrictInstances"
        Effect   = "Deny"
        Action   = ["ec2:RunInstances"]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "ec2:InstanceType" = [
              "t3.small",
              "t3.medium"
            ]
          }
        }
      }
    ]
  })
}
