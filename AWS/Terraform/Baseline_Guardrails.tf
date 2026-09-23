############################################################
# AWS – BASELINE ORGANIZATIONAL GUARDRAILS (LAYER 1)
#
# Purpose:
# Establish enterprise-wide preventive controls that should
# apply broadly across AWS member accounts.
#
# NOTE:
# These SCPs restrict permissions. They do not grant access.
############################################################


############################################################
# Restrict workloads to approved AWS Regions
#
# Global AWS services are excluded because many operate from
# global endpoints and can otherwise be unintentionally blocked.
############################################################

resource "aws_organizations_policy" "baseline_approved_regions" {
  name        = "baseline-approved-regions"
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
# Protect CloudTrail from being disabled or deleted
############################################################

resource "aws_organizations_policy" "baseline_protect_cloudtrail" {
  name        = "baseline-protect-cloudtrail"
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
# Protect AWS Config monitoring
############################################################

resource "aws_organizations_policy" "baseline_protect_config" {
  name        = "baseline-protect-config"
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
# Prevent member accounts from leaving the AWS Organization
############################################################

resource "aws_organizations_policy" "baseline_prevent_org_exit" {
  name        = "baseline-prevent-org-exit"
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
