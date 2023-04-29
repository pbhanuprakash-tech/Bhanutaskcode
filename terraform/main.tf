# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "example-rg"
  location = "eastus"
}

# Create a virtual network
resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Create public subnets
resource "azurerm_subnet" "public_subnet" {
  count               = 3
  name                = "public-subnet-${count.index + 1}"
  resource_group_name = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes    = ["10.0.${count.index}.0/24"]
}

# Create private subnets
resource "azurerm_subnet" "private_subnet" {
  count               = 3
  name                = "private-subnet-${count.index + 1}"
  resource_group_name = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes    = ["10.0.${count.index + 3}.0/24"]
}

# Create a public IP address for the VMs in the public subnet
resource "azurerm_public_ip" "public_ip" {
  count               = 2
  name                = "public-ip-${count.index + 1}"
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Dynamic"
}

# Create a network security group for the public subnet
resource "azurerm_network_security_group" "public_nsg" {
  name                = "public-nsg"
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                       = "allow_ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create a network security group for the private subnet
resource "azurerm_network_security_group" "private_nsg" {
  name                = "private-nsg"
  resource_group_name = azurerm_resource_group.example.name
}

# Create a NIC and VM in the public subnet
resource "azurerm_network_interface" "public_nic" {
  count               = 2
  name                = "public-nic-${count.index + 1}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "public-ip-config"
    subnet_id                     = azurerm_subnet.public_subnet[count.index].id
    public_ip_address_id          = azurerm_public_ip.public_ip[count.index].id
  }

  network_security_group_id = azurerm_network_security_group.public_nsg.id
}

resource "azurerm_linux_virtual_machine" "public_vm" {
  count               = 2
  name                = "public-vm-${count.index + 1}"
  resource_group_name = az

