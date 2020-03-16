provider "azurerm" {
  # The "feature" block is required for AzureRM provider 2.x. 
  # If you are using version 1.x, the "features" block is not allowed.
  version = "~>2.0"

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id


  features {}

}

resource "azurerm_resource_group" "vm" {
    name = var.resourcegroup
    location = var.location
}

resource "azurerm_virtual_network" "vm" {
  name                = "${var.vm_hostname}-network"
  address_space       = ["192.168.98.0/24"]
  location            = azurerm_resource_group.vm.location
  resource_group_name = azurerm_resource_group.vm.name
  tags                = var.tags
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.vm.name
  virtual_network_name = azurerm_virtual_network.vm.name
  address_prefix       = "192.168.98.0/24"
}



resource "azurerm_virtual_machine" "vm-linux" {
  name                          = var.vm_hostname
  location                      = var.location
  resource_group_name           = azurerm_resource_group.vm.name
  vm_size                       = var.vm_size
  network_interface_ids         = [azurerm_network_interface.vm.id]
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.vm_hostname}-osdisk"
    create_option     = "FromImage"
    caching           = "ReadWrite"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = var.vm_hostname
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  connection {
      host = azurerm_public_ip.vm.ip_address
      type = "ssh"
      user = var.admin_username
      password = var.admin_password
  }

  provisioner "file" {
    source = "caddy"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "echo Installing Inlets",
      "curl -sLS https://get.inlets.dev | sudo sh",

      "echo Installing Inlets systemd service",
      "curl -sLO https://raw.githubusercontent.com/alexellis/inlets/master/hack/inlets.service",
      "sed -i s/80/8080/g inlets.service",
      "sudo mv inlets.service /etc/systemd/system/inlets.service",      

      "echo Configuring Inlets AUTHTOKEN",
      "echo 'AUTHTOKEN=${var.inlets_authtoken}' > inlets",
      "sudo mv inlets /etc/default/inlets",

      "echo Enabling and staring Inlets",
      "sudo systemctl daemon-reload",
      "sudo systemctl start inlets.service",
      "sudo systemctl enable inlets.service",

      "echo Installing Caddy",
      "curl -OL https://github.com/caddyserver/caddy/releases/download/v2.0.0-beta.17/caddy2_beta17_linux_amd64",
      "sudo mv caddy2_beta17_linux_amd64 /usr/local/bin/caddy",
      "sudo chown root:root /usr/local/bin/caddy",
      "sudo chmod 0755 /usr/local/bin/caddy",

      "echo Configuring Caddy",
      "sudo mv /tmp/caddy /etc/caddy",
      "sudo chown -R root:root /etc/caddy",
      "sudo sed -i s/DOMAIN/${var.vm_hostname}.${var.location}.cloudapp.azure.com/g /etc/caddy/Caddyfile",
      "sudo chmod 644 /etc/caddy/Caddyfile",


      "echo Installing Caddy systemd service",
      "sudo mv /etc/caddy/caddy.service /etc/systemd/system/caddy.service",
      "sudo chown root:root /etc/systemd/system/caddy.service",
      "sudo chmod 0644 /etc/systemd/system/caddy.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl start caddy.service",
      "sudo systemctl enable caddy.service",
      "sleep 30",
      "sudo systemctl stop caddy.service",
      "sleep 3",
      "sudo systemctl start caddy.service",
    ]
  }

  tags = var.tags

  
}


resource "azurerm_public_ip" "vm" {
  name                         = "${var.vm_hostname}-ip"
  location                     = var.location
  resource_group_name          = azurerm_resource_group.vm.name
  allocation_method            = "Static"
  domain_name_label            = var.vm_hostname
}

resource "azurerm_network_interface" "vm" {
  name                      = "${var.vm_hostname}-nic"
  location                  = azurerm_resource_group.vm.location
  resource_group_name       = azurerm_resource_group.vm.name
  

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm.id
  }
}