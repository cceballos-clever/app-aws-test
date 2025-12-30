# ============================================================================
# AWS WAFv2 Web ACL – main.tf
# ============================================================================

# ========================
# 0. Provider
# ========================
provider "aws" {
  region = var.waf_region
}

# ========================
# 1. Web ACL principal
# ========================
resource "aws_wafv2_web_acl" "waf" {
  name        = var.waf_name
  description = var.waf_description
  scope       = var.waf_scope

  # Default action (permitir por ahora)
  default_action {
    allow {}
  }

  # ========================
  # 2. Known Bad Inputs
  # ========================
  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 0

    override_action { none {} }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.waf_name}-known-bad-inputs"
      sampled_requests_enabled   = true
    }
  }

  # ========================
  # 3. OWASP / Common Rule Set
  # ========================
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 2

    override_action { none {} }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.waf_name}-common-rule-set"
      sampled_requests_enabled   = true
    }
  }

  # ========================
  # 4. Geo Blocking
  # ========================
  rule {
    name     = "GeoBlockingRule"
    priority = 3

    action {
      block {}
    }

    statement {
      geo_match_statement {
        country_codes = ["RU"]
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.waf_name}-geo-blocking"
      sampled_requests_enabled   = true
    }
  }

  # ========================
  # 5. PHP Protection
  # ========================
  rule {
    name     = "AWSManagedRulesPHPRuleSet"
    priority = 4

    override_action { none {} }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesPHPRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.waf_name}-php-protection"
      sampled_requests_enabled   = true
    }
  }

  # ========================
  # 6. Bot Control
  # ========================
  rule {
    name     = "AWSManagedRulesBotControlRuleSet"
    priority = 6

    override_action { none {} }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesBotControlRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.waf_name}-bot-control"
      sampled_requests_enabled   = true
    }
  }

  # ========================
  # 7. Visibility global
  # ========================
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = var.waf_name
    sampled_requests_enabled   = true
  }

  tags = var.tags
}

# ========================
# 8. CloudWatch Log Group
# ========================
resource "aws_cloudwatch_log_group" "waf_logs" {
  name = "aws-waf-logs-${var.log_group_name}"
  tags = var.tags
}

# ========================
# 9. Logging del WAF
# ========================
resource "aws_wafv2_web_acl_logging_configuration" "waf_logging" {
  resource_arn            = aws_wafv2_web_acl.waf.arn
  log_destination_configs = [aws_cloudwatch_log_group.waf_logs.arn]

  redacted_fields {
    single_header {
      name = "authorization"
    }
  }
}

# ========================
# 10. Asociaciones
# ========================

# ALB
resource "aws_wafv2_web_acl_association" "alb" {
  count        = var.alb_arn != "" ? 1 : 0
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.waf.arn
}

# API Gateway
resource "aws_wafv2_web_acl_association" "api" {
  count        = var.api_gateway_arn != "" ? 1 : 0
  resource_arn = var.api_gateway_arn
  web_acl_arn  = aws_wafv2_web_acl.waf.arn
}

# CloudFront
resource "aws_wafv2_web_acl_association" "cloudfront" {
  count        = var.cloudfront_distribution_arn != "" ? 1 : 0
  resource_arn = var.cloudfront_distribution_arn
  web_acl_arn  = aws_wafv2_web_acl.waf.arn
}

# ========================
# 11. Outputs
# ========================
output "waf_arn" {
  value = aws_wafv2_web_acl.waf.arn
}

output "waf_name" {
  value = aws_wafv2_web_acl.waf.name
}

output "waf_log_group" {
  value = aws_cloudwatch_log_group.waf_logs.name
}
