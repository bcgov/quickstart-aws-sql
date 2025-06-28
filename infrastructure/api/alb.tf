resource "aws_alb" "app-alb" {

  name                             = var.app_name
  internal                         = true
  subnets                          = module.networking.subnets.web.ids
  security_groups                  = [module.networking.security_groups.web.id]
  enable_cross_zone_load_balancing = true
  tags                             = module.common.common_tags

  lifecycle {
    ignore_changes = [access_logs]
  }
  drop_invalid_header_fields = true
}
resource "aws_alb_listener" "internal" {
  load_balancer_arn = aws_alb.app-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.app.arn
  }
}
resource "aws_alb_target_group" "app" {
  name                 = "${var.app_name}-tg"
  port                 = var.app_port
  protocol             = "HTTP"
  vpc_id               = module.networking.vpc.id
  target_type          = "ip"
  deregistration_delay = 30

  health_check {
    healthy_threshold   = "2"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.health_check_path
    unhealthy_threshold = "2"
  }

  tags = module.common.common_tags
}