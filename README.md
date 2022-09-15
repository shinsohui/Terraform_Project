# IaC 도구를 이용하여 AWS에 Wordpress 3-tier 아키텍처 배포하기

# 1. 프로젝트 개요

## a. 프로젝트 목적

AWS 서비스와 IaC 도구인 Ansible과 Terraform를 이용하여 Terraform 프로바이더인 AWS 클라우드, Azure 클라우드 각각에 고가용성 wordpress를 배포해보는 프로젝트를 진행한다.
<br>
<br>
## b. 프로젝트 요약
![WBS](https://github.com/shinsohui/Terraform_Project/blob/main/image/WBS.png?raw=true)
<br>
<br>
## c. AWS 시스템 아키텍처

### 시스템 동작 구조

![AWS_시스템_동작](https://github.com/shinsohui/Terraform_Project/blob/main/image/AWS_%EC%8B%9C%EC%8A%A4%ED%85%9C_%EB%8F%99%EC%9E%91.png?raw=true)

전체 시스템 동작 구조는 다음과 같다.
가상머신에서 Packer를 이용해 Ansible Playbook을 실행하여 AMI 이미지를 만든다.
Terraform을 이용해 클라우드에 리소스를 생성할 때 시작템플릿 구성에 해당 이미지를 사용한다.

**사용한 서비스 목록**
| Vagrant | 가상 시스템 환경을 구축하고 관리하기위한 도구 |
| --- | --- |
| Virtual Machine | 컴퓨터 시스템을 에뮬레이션하는 소프트웨어 |
| Ansible | 오픈 소스 소프트웨어 프로비저닝, 구성 관리, 애플리케이션 전개 IaC 도구 |
| Packer | 클라우드 이미지 및 컨테이너 이미지를 자동으로 빌드하는 도구 |
| Terraform | 인프라스트럭쳐 구축 및 운영의 자동화를 지향하는 오픈 소스 IaC 도구  |
| Visual Studio Code | 디버깅 지원과 Git 제어, 구문 강조 기능등이 포함된 소스 코드 편집기 |
<br>

### 시스템 아키텍처

AWS 클라우드 시스템 아키텍처

![3-tier Wordpress](https://raw.githubusercontent.com/shinsohui/Terraform_Project/d2974f13dc973b82e8c5b315de880bceb199f1f0/image/3-tier%20Wordpress.svg)

### 전체 아키텍처 개요

가용영역 2개에 각각 퍼블릭 서브넷 1개 프라이빗 서브넷 2개를 둔다.

퍼블릭 서브넷에는 배스천 호스트를 두어 로드 밸런서를 통하지 않으면 wordpress 서버 내부에 접근할 수 없도록 한다.

프라이빗 서브넷 영역에는 wordpress를 배포한 ec2 인스턴스 웹 서버와 데이터가 저장되는 RDS 데이터베이스가 위치하는데 이 때 웹 서버에 장애가 발생해도 데이터에는 손상이 없도록 하기위해 같은 프라이빗 영역에 배치하지 않았다.

DB 백업본을 다른 가용영역의 프라이빗 서브넷에 두어 DB 고가용성을 만족시킬 수 있다.

관리자는 SSH를 이용해 배스천 호스트를 통해 wordpress 서버, DB 서버에 직접 접속할 수 있으며

사용자는 ELB를 통해 외부에서 wordpress 서버에 접속할 수 있다.

ELB를 사용해 사용자 트래픽이 몰릴 경우 트래픽을 분배할 수 있으며 서버가 무너지는 경우를 대비해 오토 스케일링을 구성하였다.
<br>
<br>

**사용한 AWS 서비스 목록**

| VPC | 가상 네트워크 구축  |
| --- | --- |
| EC2 | 가상 컴퓨터를 이용한 wordpress  웹 서비스, 서비스 관리를 위한 Bastion Host |
| RDS | wordpress DB 용 관리형 데이터베이스   |
| ELB | wordpress EC2 인스턴스에 로드 밸런싱 |
| Auto Scaling | wordpress EC2 인스턴스에 오토 스케일링 |
---

