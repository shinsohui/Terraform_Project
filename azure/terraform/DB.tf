# db서버
resource "azurerm_mariadb_server" "mariadb-server" {
  name                = "wp-mariadb-server"
  location            = azurerm_resource_group.wp_rg.location       # 영역
  resource_group_name = azurerm_resource_group.wp_rg.name           # 리소스 이름

  administrator_login          = var.mariadb-admin-login        # 관리자 이름 지정
  administrator_login_password = var.mariadb-admin-password     # 비밀번호 지정

  sku_name = var.mariadb-sku-name       # Maria DB 서버의 sku 이름 지정
  version  = var.mariadb-version        # Maria DB 서버의 버전(10.2)

  storage_mb        = var.mariadb-storage   # 저장 공간 크기
  auto_grow_enabled = true      # 자동 확장 기능

  backup_retention_days        = 7      # 백업 데이터 보존 기간
  geo_redundant_backup_enabled = false # geo 기반 백업 x
  ssl_enforcement_enabled = false       # ssl 접속 옵션 해제
}

# wordpress DB 생성
resource "azurerm_mariadb_database" "mariadb-db" {
  name                = "wordpress"     # 데이터베이스 이름
  resource_group_name = azurerm_resource_group.wp_rg.name       # 리소스 그룹
  server_name         = azurerm_mariadb_server.mariadb-server.name  # DB 서버의 이름
  charset             = "utf8"      # character set
  collation           = "utf8_unicode_ci"   # 데이터 베이스에 대한 데이터 정렬 지정
}


# 데이터 베이스 서버의 방화벽
resource "azurerm_mariadb_firewall_rule" "mariadb-fw-rule" {
  name                = "mariadbOfficeAccess"
  resource_group_name = azurerm_resource_group.wp_rg.name       # 리소스 그룹
  server_name         = azurerm_mariadb_server.mariadb-server.name      # 서버의 이름
  start_ip_address    = "0.0.0.0"       # IP 주소 범위 설정 (시작 주소)
  end_ip_address      = "255.255.255.255" # IP 주소 범위 설정 (끝 주소)
}
