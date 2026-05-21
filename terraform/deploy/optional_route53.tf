# ------------------------------------------------------------------------------
# OPTIONAL: Route 53 + custom domain + HTTPS
# ------------------------------------------------------------------------------
# Not active by default. Uncomment sections below (and related bits in
# optional_private_networking.tf / alb.tf) when you want a friendly URL.
#
# Prerequisites:
#   - A domain with a Route 53 hosted zone (or create one here).
#   - ACM certificate in the SAME region as the ALB (request + DNS validate).
#
# After apply: app_url becomes https://<your-domain> instead of the ALB DNS name.
# ------------------------------------------------------------------------------

# --- Variables (add to variables.tf) -------------------------------------------
#
# variable "domain_name" {
#   description = "FQDN for the app, e.g. contacts.example.com"
#   type        = string
#   default     = ""
# }
#
# variable "route53_zone_id" {
#   description = "Existing Route 53 hosted zone ID for the domain's parent zone"
#   type        = string
#   default     = ""
# }
#
# variable "acm_certificate_arn" {
#   description = "ACM certificate ARN (must be in var.aws_region) for HTTPS on the ALB"
#   type        = string
#   default     = ""
# }


# --- Option A: Use an existing hosted zone ------------------------------------
#
# data "aws_route53_zone" "main" {
#   zone_id = var.route53_zone_id
# }


# --- Option B: Create a new hosted zone (if you register the domain in R53) ---
#
# resource "aws_route53_zone" "main" {
#   name = "example.com"
#
#   tags = {
#     Name = "${local.name_prefix}-zone"
#   }
# }


# --- Alias record: your domain → ALB ------------------------------------------
#
# resource "aws_route53_record" "app" {
#   zone_id = data.aws_route53_zone.main.zone_id # or aws_route53_zone.main.zone_id
#   name    = var.domain_name                    # e.g. contacts.example.com
#   type    = "A"
#
#   alias {
#     name                   = aws_lb.main.dns_name
#     zone_id                = aws_lb.main.zone_id
#     evaluate_target_health = true
#   }
# }
#
# # Optional: same record for IPv6
# # resource "aws_route53_record" "app_aaaa" {
# #   zone_id = data.aws_route53_zone.main.zone_id
# #   name    = var.domain_name
# #   type    = "AAAA"
# #
# #   alias {
# #     name                   = aws_lb.main.dns_name
# #     zone_id                = aws_lb.main.zone_id
# #     evaluate_target_health = true
# #   }
# # }


# --- ACM certificate (alternative: create cert in console, pass ARN var) ----
#
# resource "aws_acm_certificate" "app" {
#   domain_name       = var.domain_name
#   validation_method = "DNS"
#
#   lifecycle {
#     create_before_destroy = true
#   }
# }
#
# resource "aws_route53_record" "acm_validation" {
#   for_each = {
#     for dvo in aws_acm_certificate.app.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }
#
#   zone_id = data.aws_route53_zone.main.zone_id
#   name    = each.value.name
#   type    = each.value.type
#   records = [each.value.record]
#   ttl     = 60
# }
#
# resource "aws_acm_certificate_validation" "app" {
#   certificate_arn         = aws_acm_certificate.app.arn
#   validation_record_fqdns = [for r in aws_route53_record.acm_validation : r.fqdn]
# }


# --- HTTPS listener on ALB (add to alb.tf or uncomment here) ------------------
#
# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.main.arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
#   certificate_arn   = var.acm_certificate_arn # or aws_acm_certificate_validation.app.certificate_arn
#
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.frontend.arn
#   }
# }
#
# # Copy path rules from aws_lb_listener.http — point listener_arn to https instead.
#
# resource "aws_lb_listener" "http_redirect" {
#   load_balancer_arn = aws_lb.main.arn
#   port              = 80
#   protocol          = "HTTP"
#
#   default_action {
#     type = "redirect"
#     redirect {
#       port        = "443"
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#     }
#   }
# }
#
# # security_groups.tf — allow ALB ingress on 443:
# #   ingress { from_port = 443 to_port = 443 protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] }


# --- Outputs (add to outputs.tf) -----------------------------------------------
#
# output "app_fqdn" {
#   description = "Custom domain for the application"
#   value       = var.domain_name
# }
#
# output "app_url_https" {
#   description = "HTTPS URL when Route 53 + ACM are enabled"
#   value       = "https://${var.domain_name}"
# }
