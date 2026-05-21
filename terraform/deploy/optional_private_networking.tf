# ------------------------------------------------------------------------------
# OPTIONAL: Private subnets for ECS + NAT Gateway (production-style networking)
# ------------------------------------------------------------------------------
# Current setup (active):
#   - ECS + ALB → public subnets, assign_public_ip = true, no NAT (~$32/mo saved)
#   - RDS      → private subnets (no internet route; already isolated)
#
# This file shows how to move ECS to private subnets with outbound via NAT.
# Uncomment blocks below and update ecs.tf / security_groups.tf as noted.
# ------------------------------------------------------------------------------

# --- Variables (add to variables.tf) -------------------------------------------
#
# variable "enable_nat_gateway" {
#   description = "Create NAT Gateway so private subnets can reach the internet"
#   type        = bool
#   default     = false
# }
#
# variable "ecs_use_private_subnets" {
#   description = "Run Fargate tasks in private subnets (requires NAT or VPC endpoints)"
#   type        = bool
#   default     = false
# }


# --- Elastic IP + NAT Gateway (one NAT; add count for per-AZ HA) ---------------
#
# resource "aws_eip" "nat" {
#   count  = var.enable_nat_gateway ? 1 : 0
#   domain = "vpc"
#
#   tags = {
#     Name = "${local.name_prefix}-nat-eip"
#   }
#
#   depends_on = [aws_internet_gateway.main]
# }
#
# resource "aws_nat_gateway" "main" {
#   count         = var.enable_nat_gateway ? 1 : 0
#   allocation_id = aws_eip.nat[0].id
#   subnet_id     = aws_subnet.public[0].id # NAT lives in a public subnet
#
#   tags = {
#     Name = "${local.name_prefix}-nat"
#   }
#
#   depends_on = [aws_internet_gateway.main]
# }


# --- Private route table: 0.0.0.0/0 → NAT -------------------------------------
#
# resource "aws_route_table" "private" {
#   count  = var.enable_nat_gateway ? 1 : 0
#   vpc_id = aws_vpc.main.id
#
#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.main[0].id
#   }
#
#   tags = {
#     Name = "${local.name_prefix}-private-rt"
#   }
# }
#
# resource "aws_route_table_association" "private" {
#   count = var.enable_nat_gateway ? length(aws_subnet.private) : 0
#
#   subnet_id      = aws_subnet.private[count.index].id
#   route_table_id = aws_route_table.private[0].id
# }


# --- Alternative to NAT: VPC interface endpoints (common for Fargate) ---------
# Cheaper at low traffic than NAT for ECR/logs only; add more endpoints as needed.
#
# resource "aws_security_group" "vpc_endpoints" {
#   name        = "${local.name_prefix}-vpc-endpoints"
#   description = "Allow HTTPS from ECS tasks to interface endpoints"
#   vpc_id      = aws_vpc.main.id
#
#   ingress {
#     description     = "HTTPS from ECS"
#     from_port       = 443
#     to_port         = 443
#     protocol        = "tcp"
#     security_groups = [aws_security_group.ecs.id]
#   }
#
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }
#
# resource "aws_vpc_endpoint" "ecr_api" {
#   vpc_id              = aws_vpc.main.id
#   service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = aws_subnet.private[*].id
#   security_group_ids  = [aws_security_group.vpc_endpoints.id]
#   private_dns_enabled = true
# }
#
# resource "aws_vpc_endpoint" "ecr_dkr" {
#   vpc_id              = aws_vpc.main.id
#   service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = aws_subnet.private[*].id
#   security_group_ids  = [aws_security_group.vpc_endpoints.id]
#   private_dns_enabled = true
# }
#
# resource "aws_vpc_endpoint" "logs" {
#   vpc_id              = aws_vpc.main.id
#   service_name        = "com.amazonaws.${var.aws_region}.logs"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = aws_subnet.private[*].id
#   security_group_ids  = [aws_security_group.vpc_endpoints.id]
#   private_dns_enabled = true
# }
#
# resource "aws_vpc_endpoint" "secretsmanager" {
#   vpc_id              = aws_vpc.main.id
#   service_name        = "com.amazonaws.${var.aws_region}.secretsmanager"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = aws_subnet.private[*].id
#   security_group_ids  = [aws_security_group.vpc_endpoints.id]
#   private_dns_enabled = true
# }
#
# resource "aws_vpc_endpoint" "s3" {
#   vpc_id            = aws_vpc.main.id
#   service_name      = "com.amazonaws.${var.aws_region}.s3"
#   vpc_endpoint_type = "Gateway"
#   route_table_ids   = [aws_route_table.private[0].id] # gateway endpoint uses route tables
# }


# --- ECS: switch tasks to private subnets (edit ecs.tf) -----------------------
#
# In aws_ecs_service.backend and aws_ecs_service.frontend network_configuration:
#
#   subnets          = var.ecs_use_private_subnets ? aws_subnet.private[*].id : aws_subnet.public[*].id
#   assign_public_ip = var.ecs_use_private_subnets ? false : true
#
# ALB stays in public subnets (alb.tf — no change).
# RDS stays in private subnets (rds.tf — no change).


# --- Optional: dedicated “app” private subnets (cleaner tier separation) ----
# Today private subnets = RDS only. You can add a second private tier for ECS:
#
# resource "aws_subnet" "private_app" {
#   count = 2
#
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 20)
#   availability_zone = data.aws_availability_zones.available.names[count.index]
#
#   tags = {
#     Name = "${local.name_prefix}-private-app-${count.index + 1}"
#     Tier = "private-app"
#   }
# }
#
# resource "aws_route_table_association" "private_app" {
#   count = var.enable_nat_gateway ? length(aws_subnet.private_app) : 0
#
#   subnet_id      = aws_subnet.private_app[count.index].id
#   route_table_id = aws_route_table.private[0].id
# }
#
# Use aws_subnet.private_app[*].id for ECS; keep aws_subnet.private[*].id for RDS only.
