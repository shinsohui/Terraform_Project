# application loadbalancer를 사용하기 위해 선언
resource "aws_alb" "project-elb" {
  name                             = "project-alb"
  internal                         = false # internet facing 설정
  load_balancer_type               = "application"
  security_groups                  = [aws_security_group.publicSG01.id]
# 외부에서 들어오는 HTTP 허용
  subnets                          = [module.app_vpc.public_subnets[0], module.app_vpc.public_subnets[1]]
  enable_cross_zone_load_balancing = true
}

# alb에 연결할 Auto Scaling 타겟 그룹을 지정한다.
resource "aws_alb_target_group" "project-elb-tg" {
  name     = "tset-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id = module.app_vpc.vpc_id
}

# alb에 지정한 Auto Scaling 타겟 그룹 연결  
resource "aws_autoscaling_attachment" "wp-atsg-attach" {
  autoscaling_group_name = aws_autoscaling_group.project-ASG.name
  alb_target_group_arn   = aws_alb_target_group.project-elb-tg.arn
}

# 로드밸런서 리스너 리소스를 설정한다. 
resource "aws_alb_listener" "project-elb-listener" {
  load_balancer_arn = aws_alb.project-elb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.project-elb-tg.arn
  }
}
