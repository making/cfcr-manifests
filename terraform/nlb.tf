resource "aws_security_group" "master" {
  name        = "${var.prefix}-bosh-master"
  description = "Master Security Group"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
  }
  
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
    from_port   = 8443
    to_port     = 8443
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }
}

resource "aws_security_group" "ldaps" {
  name        = "${var.prefix}-bosh-ldaps"
  description = "LDAPS Security Group"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
    from_port   = 636
    to_port     = 636
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }
}

resource "aws_security_group" "prometheus_proxy" {
  name        = "${var.prefix}-prometheus-proxy"
  description = "Prometheus Proxy Security Group"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
    from_port   = 7001
    to_port     = 7001
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
    from_port   = 32754
    to_port     = 32754
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }
}

resource "aws_lb" "bosh" {
  name                             = "${var.prefix}-bosh-lb"
  subnets                          = ["${aws_subnet.public.*.id}"]
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = true
}

resource "aws_lb_listener" "bosh_master" {
  load_balancer_arn = "${aws_lb.bosh.arn}"
  port              = 443
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${var.ssl_cert_arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.bosh_master.arn}"
  }
}

resource "aws_lb_listener" "bosh_ldaps" {
  load_balancer_arn = "${aws_lb.bosh.arn}"
  port              = 636
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${var.ssl_cert_arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.bosh_ldaps.arn}"
  }
}

resource "aws_lb_listener" "prometheus_proxy" {
  load_balancer_arn = "${aws_lb.bosh.arn}"
  port              = 7001
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.prometheus_proxy.arn}"
  }
}

resource "aws_lb_target_group" "bosh_master" {
  name     = "${var.prefix}-bosh-master"
  port     = 8443
  protocol = "TLS"
  vpc_id   = "${aws_vpc.vpc.id}"

  health_check {
    protocol = "TCP"
  }
}

resource "aws_lb_target_group" "bosh_ldaps" {
  name     = "${var.prefix}-bosh-ldaps"
  port     = 636
  protocol = "TLS"
  vpc_id   = "${aws_vpc.vpc.id}"

  health_check {
    protocol = "TCP"
  }
}

resource "aws_lb_target_group" "prometheus_proxy" {
  name     = "${var.prefix}-prometheus-proxy"
  port     = 32754
  protocol = "TCP"
  vpc_id   = "${aws_vpc.vpc.id}"

  health_check {
    protocol = "TCP"
  }
}

resource "aws_route53_record" "ldap" {
  zone_id = "Z19IP7K49DB2RN"
  name    = "ldap.ik.am"
  type    = "CNAME"
  ttl     = 60

  records = ["${aws_lb.bosh.dns_name}"]
}

resource "aws_route53_record" "master" {
  zone_id = "Z1IYLCI9Z4L71D"
  name    = "k8s.bosh.tokyo"
  type    = "CNAME"
  ttl     = 60

  records = ["${aws_lb.bosh.dns_name}"]
}

resource "aws_route53_record" "prometheus_proxy" {
  zone_id = "Z1IYLCI9Z4L71D"
  name    = "prometheus-proxy.dev.bosh.tokyo"
  type    = "CNAME"
  ttl     = 60

  records = ["${aws_lb.bosh.dns_name}"]
}