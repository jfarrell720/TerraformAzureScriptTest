provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "sqlserver-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "sqlserver-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = "sqlserver-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic" {
  name                = "sqlserver-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "sqlserver-ipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                  = var.vm_name
  resource_group_name   = azurerm_resource_group.rg.name
  location              = var.location
  size                  = var.vm_size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter"
    version   = "latest"
  }

  provision_vm_agent = true

  tags = {
    environment = var.environment
  }
}

resource "azurerm_virtual_machine_extension" "sql_install" {
  name                 = "sqlserver-install"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
      "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -Command \"Invoke-WebRequest -Uri 'https://go.microsoft.com/fwlink/?linkid=866658' -OutFile 'C:\\sql_express.exe'; Start-Process -Wait -FilePath 'C:\\sql_express.exe' -ArgumentList '/Q /ACTION=Install /FEATURES=SQL /INSTANCENAME=SQLEXPRESS /SECURITYMODE=SQL /SAPWD=P@ssw0rd123!'\""
    }
SETTINGS
}


#Alert group for monitoring
resource "azurerm_monitor_action_group" "email_group" {
  name                    = "JamesIncidentAlertGroup"
  resource_group_name     = azurerm_resource_group.rg.name
  short_name              = "JamesAG"
  email_receiver {
    name                    = "OpsEmail"
    email_address           = var.ops_email
  }
}


#Alerts for monitoring
resource "azurerm_monitor_metric_alert" "cpu_metric" {
  name                     = "90 CPU Alert"
  resource_group_name      = azurerm_resource_group.rg.name
  description              = "CPU usage alert has exceeded 90 over 10 minutes"
  severity                 = 1
  scopes                   = [azurerm_windows_virtual_machine.vm.id]
  action {
    action_group_id = azurerm_monitor_action_group.email_group.id
  }

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name        = "Percentage CPU"
    aggregation        = "Average"
    operator           = "GreaterThan"
    threshold          = 90
  }
  window_size = "PT5M"
  enabled = true
}