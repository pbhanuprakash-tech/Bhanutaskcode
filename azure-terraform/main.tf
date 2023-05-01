resource "azurerm_resource_group" "myresourcegroup" {
  name     = "myresourcegroup"
  location = "eastus"
}

resource "azurerm_virtual_network" "myvnet" {
  name                = "myvnet"
  address_space       = ["10.0.0.0/16"]
  location            = "eastus"
  resource_group_name = azurerm_resource_group.myresourcegroup.name
}

resource "azurerm_subnet" "private_subnet" {
  count                   = 3
  name                    = "private_subnet_${count.index}"
  resource_group_name     = azurerm_resource_group.myresourcegroup.name
  virtual_network_name    = azurerm_virtual_network.myvnet.name
  address_prefixes        = ["10.0.${count.index}.0/24"]
}

resource "azurerm_subnet" "public_subnet" {
  count                   = 3
  name                    = "public_subnet_${count.index}"
  resource_group_name     = azurerm_resource_group.myresourcegroup.name
  virtual_network_name    = azurerm_virtual_network.myvnet.name
  address_prefixes        = ["10.0.${count.index + 3}.0/24"]
}

resource "azurerm_network_security_group" "private_nsg" {
  name                = "private_nsg"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.myresourcegroup.name
}
resource "azurerm_network_security_group" "public_nsg" {
  name                = "public_nsg"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.myresourcegroup.name
}

resource "azurerm_network_security_rule" "private_nsg_rule" {
  count                       = 2
  name                        = "private_nsg_rule_${count.index}"
  priority                    = 100 + count.index
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_address_prefix       = "*"
  source_port_range           = "*"
  destination_address_prefix  = azurerm_subnet.private_subnet.*.address_prefixes[count.index][0]
  destination_port_range      = "*"
  description                 = "Allow all inbound traffic to private subnet ${count.index}"
  network_security_group_name = azurerm_network_security_group.private_nsg.name
  resource_group_name = azurerm_resource_group.myresourcegroup.name
}

resource "azurerm_network_security_rule" "public_nsg_rule" {
  count                       = 2
  name                        = "public_nsg_rule_${count.index}"
  priority                    = 100 + count.index
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_address_prefix       = "*"
  source_port_range           = "*"
  destination_address_prefix  = azurerm_subnet.public_subnet.*.address_prefixes[count.index][0]
  destination_port_range      = "*"
  description                 = "Allow all inbound traffic to public subnet ${count.index}"
  network_security_group_name = azurerm_network_security_group.public_nsg.name
  resource_group_name = azurerm_resource_group.myresourcegroup.name
}

resource "azurerm_network_interface" "private_nic" {
  count                   = 2
  name                    = "private_nic_${count.index}"
  location                = "eastus"
  resource_group_name     = azurerm_resource_group.myresourcegroup.name
  ip_configuration {
    name                          = "private_ip_configuration_${count.index}"
    subnet_id                     = azurerm_subnet.private_subnet.*.id[count.index]
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_public_ip" "public_ip" {
  name                = "public-ip"
  location            = azurerm_resource_group.myresourcegroup.location
  resource_group_name = azurerm_resource_group.myresourcegroup.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "public_nic" {
  count                   = 2
  name                    = "public_nic_${count.index}"
  location                = "eastus"
  resource_group_name     = azurerm_resource_group.myresourcegroup.name
  ip_configuration {
    name                          = "public_ip_configuration_${count.index}"
    subnet_id                     = azurerm_subnet.public_subnet.*.id[count.index]
    #  public_ip_address_id          = azurerm_public_ip.public_ip.*.id[count.index][0]
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_virtual_machine" "private_vm" {
  count                   = 2
  name                    = "private-vm-${count.index}"
  location                = "eastus"
  resource_group_name     = azurerm_resource_group.myresourcegroup.name
  network_interface_ids   = [azurerm_network_interface.private_nic.*.id[count.index]]
  vm_size                 = "Standard_B1s"
  storage_os_disk {
    name              = "private-os-disk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "private-vm-${count.index}"
    admin_username = "adminuser"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
resource "azurerm_virtual_machine" "public_vm" {
  count                   = 2
  name                    = "public-vm-${count.index}"
  location                = "eastus"
  resource_group_name     = azurerm_resource_group.myresourcegroup.name
  network_interface_ids   = [azurerm_network_interface.public_nic.*.id[count.index]]
  vm_size                 = "Standard_B1s"
  storage_os_disk {
    name              = "public-os-disk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "public-vm-${count.index}"
    admin_username = "adminuser"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

