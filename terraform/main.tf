provider "aws" {
  region = "ap-northeast-1"
}

variable "enable_db_maintenance" {
  default = false
}

variable "db_maintenance_address" {
  type = string
  default = "3.112.81.196/32"
}

variable "db_password" {
}

resource "aws_vpc" "snssample" {
  cidr_block = "10.1.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "snssample" {
  vpc_id = aws_vpc.snssample.id
}

resource "aws_subnet" "snssample1a" {
  vpc_id = aws_vpc.snssample.id
  availability_zone = "ap-northeast-1a"
  cidr_block = "10.1.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "snssample1c" {
  vpc_id = aws_vpc.snssample.id
  availability_zone = "ap-northeast-1c"
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = true
}

resource "aws_route_table" "snssample" {
  vpc_id = aws_vpc.snssample.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.snssample.id
  }
}

resource "aws_route_table_association" "snssample1a" { 
  subnet_id = aws_subnet.snssample1a.id
  route_table_id = aws_route_table.snssample.id
}

resource "aws_route_table_association" "snssample1c" {
  subnet_id = aws_subnet.snssample1c.id
  route_table_id = aws_route_table.snssample.id
}

resource "aws_network_acl" "snssample" {
  vpc_id = aws_vpc.snssample.id
  egress {
    protocol = "-1"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }
  ingress {
    protocol = "-1"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }
}

resource "aws_network_acl_association" "snssample1a" {
  network_acl_id = aws_network_acl.snssample.id
  subnet_id = aws_subnet.snssample1a.id
}

resource "aws_network_acl_association" "snssample1c" {
  network_acl_id = aws_network_acl.snssample.id
  subnet_id = aws_subnet.snssample1c.id
}

resource "aws_security_group" "snssample" {
  name = "HTTP_ONLY"
  vpc_id = aws_vpc.snssample.id
  description = "http only"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "snssample" {
  count = "${var.enable_db_maintenance ? 1 : 0}"
  type = "ingress"
  protocol = "tcp"
  security_group_id = aws_security_group.snssamplesg.id
  from_port = 3306
  to_port = 3306
  cidr_blocks = ["${var.db_maintenance_address}"]
}

resource "aws_lb" "snssample" {
  load_balancer_type = "application"
  name = "snssamplealb"

  security_groups = [aws_security_group.snssample.id]
  subnets = [aws_subnet.snssample1a.id, aws_subnet.snssample1c.id]
}

resource "aws_lb_target_group" "snssample" {
  name = "snssampletg"
  vpc_id = aws_vpc.snssample.id

  port = 80
  protocol = "HTTP"
  target_type = "ip"

  health_check {
    port = 80
    path = "/"
  }
}

resource "aws_lb_listener" "snssample" {
  port              = 80
  protocol          = "HTTP"

  load_balancer_arn = aws_lb.snssample.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.snssample.id
  }
}

resource "aws_ecs_cluster" "snssample" {
  name = "snssamplecluster"
}

resource "aws_security_group" "snssamplesg" {
  name = "RDS"
  vpc_id = aws_vpc.snssample.id
  description = "for RDS"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["10.1.1.0/24","10.1.2.0/24"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "snssamplesubnet" {
  name        = "snssamplerds"
  description = "subnet group"
  subnet_ids  = [aws_subnet.snssample1a.id,aws_subnet.snssample1c.id]
}

resource "aws_db_instance" "snssampledb" {
  allocated_storage      = 10
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0.20"
  instance_class         = "db.t2.micro"
  identifier             = "snssampledb"
  username               = "admin"
  password               = "${var.db_password}"
  publicly_accessible    = false
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.snssamplesg.id]
  db_subnet_group_name   = aws_db_subnet_group.snssamplesubnet.name
}
