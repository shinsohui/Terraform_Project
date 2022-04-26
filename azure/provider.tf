
# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = "0e337d72-f370-4cb8-9749-9968126b71df"
  client_id       = "4b3914fd-9548-430d-afce-12cbf51c382b"
  client_secret   = "87Y-NV3QsuI1s03hrCqI-6OIgxPY_cUu0r"
  tenant_id       = "40c79e45-8666-45ec-9af1-b4a931926789"

}