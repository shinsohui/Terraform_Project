resource "aws_alb" "project-elb" {
  name                             = "project-alb"
  internal                         = false # internet facing 설정
  load_balancer_type               = "application"
  security_groups                  = [aws_security_group.publicSG01.id]                                   # 외부에서 들어오는 HTTP 허용
  subnets                          = [module.app_vpc.public_subnets[0], module.app_vpc.public_subnets[1]] # private subnet으로 들어오는
  enable_cross_zone_load_balancing = true
}

resource "aws_alb_target_group" "project-elb-tg" {
  name     = "tset-alb-tg"
  port     = 80
  protocol = "HTTP"
  # vpc_id   = aws_vpc.project-vpc.id
  vpc_id = module.app_vpc.vpc_id
}

# resource "aws_alb_target_group_attachment" "privateInstance01" {
#   target_group_arn = aws_alb_target_group.project-elb-tg.arn
#   target_id        = aws_instance.project-EC2-01.id
#   port             = 80
# }

# resource "aws_alb_target_group_attachment" "privateInstance02" {
#   target_group_arn = aws_alb_target_group.project-elb-tg.arn
#   target_id        = aws_instance.project-EC2-02.id
#   port             = 80
# }

resource "aws_alb_listener" "project-elb-listener" {
  load_balancer_arn = aws_alb.project-elb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.project-elb-tg.arn
  }
}
