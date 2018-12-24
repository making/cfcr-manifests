resource "aws_lb_target_group" "cfcr_scgw_https" {
  name     = "${var.prefix}-cfcr-scgw-https"
  port     = "32765"
  protocol = "HTTPS"
  vpc_id   = "${aws_vpc.vpc.id}"
  count    = "${var.use_alb ? 1 : 0}"
  health_check {
    protocol = "HTTPS"
    path = "/management/health"
    port = 32765
    matcher = "200"    healthy_threshold   = 6
    unhealthy_threshold = 3
    timeout             = 3
    interval            = 5
  }
}

resource "aws_lb_listener_rule" "cfcr_scgw_https_ikam" {
  listener_arn = "${aws_lb_listener.front_end.arn}"
  priority     = 30
  count        = "${var.use_alb ? 1 : 0}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.cfcr_scgw_https.arn}"
  }

  condition {
    field  = "host-header"
    values = ["*.ik.am"]
  }
}

resource "aws_lb_listener_rule" "cfcr_scgw_https" {
  listener_arn = "${aws_lb_listener.front_end.arn}"
  priority     = 50
  count        = "${var.use_alb ? 1 : 0}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.cfcr_scgw_https.arn}"
  }

  condition {
    field  = "host-header"
    values = ["*.k8s.bosh.tokyo"]
  }
}

resource "aws_route53_record" "cfcr_scgw" {
  zone_id = "Z1IYLCI9Z4L71D"
  name    = "*.k8s.bosh.tokyo"
  type    = "CNAME"
  ttl     = 60

  records = ["${aws_lb.front_end.dns_name}"]
}

resource "aws_lb_listener_rule" "cfcr_scgw_dev" {
  listener_arn = "${aws_lb_listener.front_end.arn}"
  priority     = 52
  count        = "${var.use_alb ? 1 : 0}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.cfcr_scgw_https.arn}"
  }

  condition {
    field  = "host-header"
    values = ["*.dev.bosh.tokyo"]
  }
}

resource "aws_route53_record" "cfcr_scgw_dev" {
  zone_id = "Z1IYLCI9Z4L71D"
  name    = "*.dev.bosh.tokyo"
  type    = "CNAME"
  ttl     = 60

  records = ["${aws_lb.front_end.dns_name}"]
}
