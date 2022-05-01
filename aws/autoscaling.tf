# web server가 구동될 EC2들을 Auto Scaling하기 위한 Auto Scaling Group 생성
resource "aws_autoscaling_group" "project-ASG" {
  launch_template {
    id = aws_launch_template.project-launch-template.id

  }

  desired_capacity = 2 # 원하는 인스턴스의 개수 2개
  min_size         = 2 # 최소 인스턴스 개수 2개
  max_size         = 4 # 최대 인스턴스 개수 4개

  health_check_type         = "ELB"
  health_check_grace_period = 180 # 3분
  force_delete              = true
  vpc_zone_identifier       = [module.app_vpc.private_subnets[0], module.app_vpc.private_subnets[1]]
  # availability_zones        = ["ap-northeast-2a", "ap-northeast-2c"]

}


