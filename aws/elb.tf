# # output "public_ip" {
# #     value = "${aws_instance.example.public_ip}"
# # }

# output "elb_dns_name" {
#   value = aws_elb.project-elb.dns_name
# }

# variable "server_port" {
#   description = "The port the server will use for HTTP requests"
#   default     = "8080"
# }

# data "aws_availability_zones" "all" {


# }

# resource "aws_security_group" "elb" {
#   name = "project-elb-sg"

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_security_group" "instance" {
#   name = "ch4njun-example-instance"

#   ingress {
#     from_port   = var.server_port
#     to_port     = var.server_port
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_launch_configuration" "project-lc" {
#   image_id        = data.aws_ami.amazonLinux.id
#   instance_type   = "t2.micro"
#   security_groups = ["${aws_security_group.instance.id}"]

#   user_data = <<-EOF
#                 #!/bin/bash
#                 echo "Hello, World" > index.html
#                 nohup busybox httpd -f -p "${var.server_port}" &
#                 EOF

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_elb" "project-elb" {
#   name               = "project-elb"
#   availability_zones = data.aws_availability_zones.all.names
#   security_groups    = ["${aws_security_group.elb.id}"]

#   listener {
#     lb_port           = 80
#     lb_protocol       = "http"
#     instance_port     = var.server_port
#     instance_protocol = "http"
#   }

#   health_check {
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#     timeout             = 3
#     interval            = 30
#     target              = "HTTP:${var.server_port}/"
#   }
# }

# resource "aws_autoscaling_group" "project-ASG" {
#   launch_configuration = aws_launch_configuration.project-lc.id
#   availability_zones   = data.aws_availability_zones.all.names

#   load_balancers    = ["${aws_elb.project-elb.name}"]
#   health_check_type = "ELB"

#   min_size = "2"
#   max_size = "10"

#   tag {
#     key                 = "Name"
#     value               = "ch4njun-asg-example"
#     propagate_at_launch = true
#   }
# }