resource "azurerm_resource_group" "RG_AKSCluster_WKS" {
  name     = var.resourceGroupName
  location = var.azureRegion
}

resource "azurerm_virtual_network" "terra_vnet_wks" {
  name                = var.vnetName
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.RG_AKSCluster_WKS.location
  resource_group_name = azurerm_resource_group.RG_AKSCluster_WKS.name
}

resource "azurerm_subnet" "terra_subnet_wks" {
  name                 = var.subnetName
  resource_group_name  = azurerm_resource_group.RG_AKSCluster_WKS.name
  virtual_network_name = azurerm_virtual_network.terra_vnet_wks.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "terra_nic_wks" {
  name                = var.nicName
  location            = azurerm_resource_group.RG_AKSCluster_WKS.location
  resource_group_name = azurerm_resource_group.RG_AKSCluster_WKS.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.terra_subnet_wks.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "terra_vm" {
  name                = var.vmName
  resource_group_name = azurerm_resource_group.RG_AKSCluster_WKS.name
  location            = azurerm_resource_group.RG_AKSCluster_WKS.location
  size                = var.vmSize
  admin_username      = var.vmUser
  network_interface_ids = [
    azurerm_network_interface.terra_nic_wks.id,
  ]

  admin_ssh_key {
    username   = var.vmUser
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical" # az vm image list --output table
    offer     = "UbuntuServer" # az vm image list --offer UbuntuServer --all --output table
    sku       = "18.04-LTS" # az vm image list-skus --location westus --publisher Canonical --offer UbuntuServer --output table
    version   = "latest"
  }
}

