# 구독 / 리소스 그룹 이름 / 영역 / tags
resource "azurerm_resource_group" "rg" {
  name     = "testResourceGroup"
  location = var.resource_group_location
  tags = {
    name = "wp" # 예시
  }
}