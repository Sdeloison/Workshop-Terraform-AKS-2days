
# lectures utiles : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account
#                   https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container


resource "azurerm_storage_account" "Terra-Storaged_wks" {
  name                      = var.storageAccountBackendTerraform
  resource_group_name       = azurerm_resource_group.rg_terra-wks.name
  location                  = azurerm_resource_group.rg_terra-wks.location
  account_tier              = "Standard"
  account_replication_type  = "GRS"
  account_kind              = "StorageV2"
  enable_https_traffic_only = true

  tags = {
    environment = "lab"
  }
}


resource "azurerm_storage_container" "Terra-Container-Storage" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.Terra-Storage-Backend.name
  container_access_type = "private"
}
