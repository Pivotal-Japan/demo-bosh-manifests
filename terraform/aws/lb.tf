variable "prefix" {
  type = "string"
}

variable "access_key" {
  type = "string"
}

variable "secret_key" {
  type = "string"
}

variable "region" {
  type = "string"
}

variable "vpc_id" {
  type = "string"
}

variable "public_subnet_ids" {
  type = "list"
}

variable "tls_cert" {
  type = "string"
  default     = ""
}

variable "tls_private_key" {
  type = "string"
  default     = ""
}

variable "base_domain" {
  type = "string"
}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_lb" "bosh-lb" {
  name            = "${var.prefix}-bosh-lb"
  subnets         = ["${var.public_subnet_ids}"]
  security_groups = ["${aws_security_group.bosh-lb.id}"]
}

resource "aws_iam_server_certificate" "bosh-lb" {
  name             = "${var.prefix}-bosh-lb"
  private_key      = "${var.tls_private_key}"
  certificate_body = "${var.tls_cert}"
  lifecycle {
    ignore_changes = ["id", "certificate_body", "certificate_chain", "private_key"]
  }
}

resource "aws_lb_listener" "bosh-lb" {
  load_balancer_arn = "${aws_lb.bosh-lb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${aws_iam_server_certificate.bosh-lb.arn}"
  default_action {
    target_group_arn = "${aws_lb_target_group.prometheus.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "prometheus" {
  name     = "${var.prefix}-prometheus"
  port     = "9090"
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  health_check {
    protocol = "HTTP"
    path = "/"
    port = 9090
    matcher = "401"
    healthy_threshold   = 6
    unhealthy_threshold = 3
    timeout             = 3
    interval            = 5
  }
}

resource "aws_lb_target_group" "grafana" {
  name     = "${var.prefix}-grafana"
  port     = "3000"
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  health_check {
    protocol = "HTTP"
    path = "/"
    port = 3000
    matcher = "401"
    healthy_threshold   = 6
    unhealthy_threshold = 3
    timeout             = 3
    interval            = 5
  }
}

resource "aws_lb_target_group" "alertmanager" {
  name     = "${var.prefix}-alertmanager"
  port     = "9093"
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  health_check {
    protocol = "HTTP"
    path = "/"
    port = 9093
    matcher = "401"
    healthy_threshold   = 6
    unhealthy_threshold = 3
    timeout             = 3
    interval            = 5
  }
}

resource "aws_lb_target_group" "concourse" {
  name     = "${var.prefix}-concourse"
  port     = "443"
  protocol = "HTTPS"
  vpc_id   = "${var.vpc_id}"
  health_check {
    protocol = "HTTPS"
    path = "/"
    port = 443
    matcher = "200"
    healthy_threshold   = 6
    unhealthy_threshold = 3
    timeout             = 3
    interval            = 5
  }
}

resource "aws_lb_target_group" "elasticsearch" {
  name     = "${var.prefix}-elasticsearch"
  port     = "443"
  protocol = "HTTPS"
  vpc_id   = "${var.vpc_id}"
  health_check {
    protocol = "HTTPS"
    path = "/"
    port = 443
    matcher = "401"
    healthy_threshold   = 6
    unhealthy_threshold = 3
    timeout             = 3
    interval            = 5
  }
}

resource "aws_lb_target_group" "kibana" {
  name     = "${var.prefix}-kibana"
  port     = "443"
  protocol = "HTTPS"
  vpc_id   = "${var.vpc_id}"
  health_check {
    protocol = "HTTPS"
    path = "/"
    port = 443
    matcher = "401"
    healthy_threshold   = 6
    unhealthy_threshold = 3
    timeout             = 3
    interval            = 5
  }
}

resource "aws_lb_target_group" "zipkin" {
  name     = "${var.prefix}-zipkin"
  port     = "9411"
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  health_check {
    protocol = "HTTP"
    path = "/actuator/health"
    port = 9411
    matcher = "200"
    healthy_threshold   = 6
    unhealthy_threshold = 3
    timeout             = 3
    interval            = 5
  }
}

resource "aws_lb_listener_rule" "prometheus" {
  listener_arn = "${aws_lb_listener.bosh-lb.arn}"
  priority     = 30
  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.prometheus.arn}"
  }
  condition {
    field  = "host-header"
    values = ["prometheus.${var.base_domain}"]
  }
}

resource "aws_lb_listener_rule" "grafana" {
  listener_arn = "${aws_lb_listener.bosh-lb.arn}"
  priority     = 31
  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.grafana.arn}"
  }
  condition {
    field  = "host-header"
    values = ["grafana.${var.base_domain}"]
  }
}

resource "aws_lb_listener_rule" "alertmanager" {
  listener_arn = "${aws_lb_listener.bosh-lb.arn}"
  priority     = 32
  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.alertmanager.arn}"
  }
  condition {
    field  = "host-header"
    values = ["alertmanager.${var.base_domain}"]
  }
}

resource "aws_lb_listener_rule" "concourse" {
  listener_arn = "${aws_lb_listener.bosh-lb.arn}"
  priority     = 25
  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.concourse.arn}"
  }
  condition {
    field  = "host-header"
    values = ["concourse.${var.base_domain}"]
  }
}

resource "aws_lb_listener_rule" "elasticsearch" {
  listener_arn = "${aws_lb_listener.bosh-lb.arn}"
  priority     = 27
  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.elasticsearch.arn}"
  }
  condition {
    field  = "host-header"
    values = ["elasticsearch.${var.base_domain}"]
  }
}

resource "aws_lb_listener_rule" "kibana" {
  listener_arn = "${aws_lb_listener.bosh-lb.arn}"
  priority     = 26
  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.kibana.arn}"
  }
  condition {
    field  = "host-header"
    values = ["kibana.${var.base_domain}"]
  }
}

resource "aws_lb_listener_rule" "zipkin" {
  listener_arn = "${aws_lb_listener.bosh-lb.arn}"
  priority     = 24
  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.zipkin.arn}"
  }
  condition {
    field  = "host-header"
    values = ["zipkin.${var.base_domain}"]
  }
}

resource "aws_security_group" "bosh-lb" {
  name   = "${var.prefix}-bosh-lb"
  vpc_id = "${var.vpc_id}"
}

resource "aws_security_group_rule" "outbound" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.bosh-lb.id}"
}

resource "aws_security_group_rule" "https" {
  type        = "ingress"
  from_port   = "443"
  to_port     = "443"
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.bosh-lb.id}"
}

output "bosh_lb_name" {
  value = "${aws_lb.bosh-lb.name}"
}

output "bosh_lb_dns_name" {
  value = "${aws_lb.bosh-lb.dns_name}"
}

output "bosh_lb_security_group" {
  value = "${aws_security_group.bosh-lb.id}"
}

output "prometheus_hostname" {
  value = "prometheus.${var.base_domain}"
}

output "grafana_hostname" {
  value = "grafana.${var.base_domain}"
}

output "alertnamager_hostname" {
  value = "alertmanager.${var.base_domain}"
}

output "kibana_hostname" {
  value = "kibana.${var.base_domain}"
}

output "elasticsearch_hostname" {
  value = "elasticsearch.${var.base_domain}"
}

output "zipkin_hostname" {
  value = "zipkin.${var.base_domain}"
}