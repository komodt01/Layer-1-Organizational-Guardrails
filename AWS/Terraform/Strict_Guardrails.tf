############################################################
# AWS – STRICT ORGANIZATIONAL GUARDRAILS (LAYER 1)
#
# Purpose:
# Apply stronger preventive controls for regulated or
# high-security environments.
#
# Strict guardrails build on the same architectural principles
# as baseline controls but reduce workload-team flexibility.
############################################################


############################################################
# Restrict workloads to approved AWS Regions
############################################################

resource "aws_organizations_policy" "strict_approved_regions" {
  name        = "strict-approved-regions"
  description = "Restrict regional AWS operations to approved regions while allowing required global services."
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "DenyOperationsOutsideApprovedRegions"
        Effect = "Deny"

        NotAction = [
          "iam:*",
          "organizations:*",
          "route53:*",
          "cloudfront:*",
          "support:*",
          "budgets:*"
        ]

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


############################################################
# Protect CloudTrail
############################################################

resource "aws_organizations_policy" "strict_protect_cloudtrail" {
  name        = "strict-protect-cloudtrail"
  description = "Prevent member accounts from disabling or deleting CloudTrail audit logging."
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid      = "ProtectCloudTrail"
        Effect   = "Deny"
        Action = [
          "cloudtrail:StopLogging",
          "cloudtrail:DeleteTrail"
        ]
        Resource = "*"
      }
    ]
  })
}


############################################################
# Protect AWS Config
############################################################

resource "aws_organizations_policy" "strict_protect_config" {
  name        = "strict-protect-config"
  description = "Prevent member accounts from disabling AWS Config recording."
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid      = "ProtectAWSConfig"
        Effect   = "Deny"
        Action = [
          "config:StopConfigurationRecorder",
          "config:DeleteConfigurationRecorder"
        ]
        Resource = "*"
      }
    ]
  })
}


############################################################
# Prevent member accounts from leaving the Organization
############################################################

resource "aws_organizations_policy" "strict_prevent_org_exit" {
  name        = "strict-prevent-org-exit"
  description = "Prevent member accounts from leaving centralized organizational governance."
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid      = "PreventLeavingOrganization"
        Effect   = "Deny"
        Action   = "organizations:LeaveOrganization"
        Resource = "*"
      }
    ]
  })
}


############################################################
# Prevent use of S3 ACLs
#
# Strict environments use policy-based access rather than
# legacy bucket/object ACL management.
############################################################

resource "aws_organizations_policy" "strict_disable_s3_acl_changes" {
  name        = "strict-disable-s3-acl-changes"
  description = "Prevent member accounts from configuring S3 bucket or object ACLs."
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid      = "DenyS3ACLChanges"
        Effect   = "Deny"
        Action = [
          "s3:PutBucketAcl",
          "s3:PutObjectAcl"
        ]
        Resource = "*"
      }
    ]
  })
}


############################################################
# Protect GuardDuty
############################################################

resource "aws_organizations_policy" "strict_protect_guardduty" {
  name        = "strict-protect-guardduty"
  description = "Prevent member accounts from deleting GuardDuty detectors."
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid      = "ProtectGuardDuty"
        Effect   = "Deny"
        Action   = "guardduty:DeleteDetector"
        Resource = "*"
      }
    ]
  })
}


############################################################
# Protect Security Hub
############################################################

resource "aws_organizations_policy" "strict_protect_securityhub" {
  name        = "strict-protect-securityhub"
  description = "Prevent member accounts from disabling Security Hub."
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid      = "ProtectSecurityHub"
        Effect   = "Deny"
        Action   = "securityhub:DisableSecurityHub"
        Resource = "*"
      }
    ]
  })
}
