# data
data "azurerm_resource_group" "image" {
  name = var.packer_resource_group_name
  depends_on          = [azurerm_resource_group.wp_rg]  # 의존성
}       # 이미지가 생성될 리소스 그룹 설정

data "azurerm_image" "image" {
  name                = var.packer_image_name       # Packer로 생성된 이미지 이름
  resource_group_name = data.azurerm_resource_group.image.name      # 이미지가 존재하는 리소스 그룹의 이름
  depends_on          = [azurerm_resource_group.wp_rg]      # 의존성
}
