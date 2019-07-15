resource "aws_lb_target_group" "cfcr_ingress_https" {
  name     = "${var.prefix}-cfcr-ingress-https"
  port     = "32162"
  protocol = "HTTPS"
  vpc_id   = "${aws_vpc.vpc.id}"
  count    = "${var.use_alb ? 1 : 0}"
  health_check {
    protocol = "HTTPS"
    path = "/healthz"
    port = 32162
    matcher = "200"    healthy_threshold   = 6
    unhealthy_threshold = 3
    timeout             = 3
    interval            = 5
  }
}

resource "aws_lb_listener_rule" "cfcr_ingress_grafana" {
  listener_arn = "${aws_lb_listener.front_end.arn}"
  priority     = 25
  count        = "${var.use_alb ? 1 : 0}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.cfcr_ingress_https.arn}"
  }

  condition {
    field  = "host-header"
    values = ["grafana.k8s.bosh.tokyo"]
  }
}

resource "aws_lb_listener_rule" "cfcr_ingress_moneygr" {
  listener_arn = "${aws_lb_listener.front_end.arn}"
  priority     = 27
  count        = "${var.use_alb ? 1 : 0}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.cfcr_ingress_https.arn}"
  }

  condition {
    field  = "host-header"
    values = ["moneygr.ik.am"]
  }
}

resource "aws_lb_listener_rule" "cfcr_ingress_note" {
  listener_arn = "${aws_lb_listener.front_end.arn}"
  priority     = 28
  count        = "${var.use_alb ? 1 : 0}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.cfcr_ingress_https.arn}"
  }

  condition {
    field  = "host-header"
    values = ["note.ik.am"]
  }
}

resource "aws_lb_listener_rule" "cfcr_ingress_build" {
  listener_arn = "${aws_lb_listener.front_end.arn}"
  priority     = 29
  count        = "${var.use_alb ? 1 : 0}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.cfcr_ingress_https.arn}"
  }

  condition {
    field  = "host-header"
    values = ["build.dev.bosh.tokyo"]
  }
}

resource "aws_route53_record" "grafana" {
  zone_id = "Z1IYLCI9Z4L71D"
  name    = "grafana.k8s.bosh.tokyo"
  type    = "CNAME"
  ttl     = 60

  records = ["${aws_lb.front_end.dns_name}"]
}

resource "aws_route53_record" "moneygr" {
  zone_id = "Z19IP7K49DB2RN"
  name    = "moneygr.ik.am"
  type    = "CNAME"
  ttl     = 60

  records = ["${aws_lb.front_end.dns_name}"]
}

resource "aws_route53_record" "note" {
  zone_id = "Z19IP7K49DB2RN"
  name    = "note.ik.am"
  type    = "CNAME"
  ttl     = 60

  records = ["${aws_lb.front_end.dns_name}"]
}

resource "aws_route53_record" "build" {
  zone_id = "Z1IYLCI9Z4L71D"
  name    = "build.dev.bosh.tokyo"
  type    = "CNAME"
  ttl     = 60

  records = ["${aws_lb.front_end.dns_name}"]
}
