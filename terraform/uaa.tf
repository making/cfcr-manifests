resource "aws_lb_target_group" "cfcr_uaa" {
  name     = "${var.prefix}-cfcr-uaa"
  port     = "9443"
  protocol = "HTTPS"
  vpc_id   = "${aws_vpc.vpc.id}"
  count    = "${var.use_alb ? 1 : 0}"
  health_check {
    protocol = "HTTPS"
    path = "/healthz"
    port = 9443
    matcher = "200"    healthy_threshold   = 6
    unhealthy_threshold = 3
    timeout             = 3
    interval            = 5
  }
}

resource "aws_lb_listener_rule" "cfcr_uaa" {
  listener_arn = "${aws_lb_listener.front_end.arn}"
  priority     = 49
  count        = "${var.use_alb ? 1 : 0}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.cfcr_uaa.arn}"
  }

  condition {
    field  = "host-header"
    values = ["uaa.bosh.tokyo"]
  }
}

resource "aws_route53_record" "cfcr_uaa" {
  zone_id = "Z1IYLCI9Z4L71D"
  name    = "uaa.bosh.tokyo"
  type    = "CNAME"
  ttl     = 60

  records = ["${aws_lb.front_end.dns_name}"]
}