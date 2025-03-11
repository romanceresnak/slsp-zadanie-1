/*
Vytvorte resource group s názvom "skolenie-slsp-rc"
Umiestnite ju v lokácii definovanej v premennej "location"
*/
resource "azurerm_resource_group" "demo" {
  name     = "skolenie-slsp-rc"
  location = var.location
}

/*
Vytvorte virtuálny stroj s názvom, ktorý začína prefixom definovaným v premennej a končí "-vm"
Umiestnite ho v lokácii definovanej v premennej "location"
Prepojte ho s vytvorenou resource group
Prepojte ho s vytvoreným sieťovým rozhraním
Nastavte veľkosť VM na "Standard_B1s"
Nastavte automatické odstránenie OS disku a dátových diskov pri zrušení VM
Nastavte referenčný obraz OS:

Publisher: "Canonical"
Offer: "0001-com-ubuntu-server-jammy"
SKU: "22_04-lts-gen2"
Verzia: "latest"


Nastavte OS disk:

Názov: "myosdisk1"
Caching: "ReadWrite"
Spôsob vytvorenia: "FromImage"
Typ spravovaného disku: "Standard_LRS"


Nastavte profil OS:

Názov počítača: "demo-instance"
Používateľské meno: "demo"
Heslo: "StrongP@ssword123!"


Nastavte konfiguráciu Linuxu s povolenou autentifikáciou heslom
*/
resource "azurerm_virtual_machine" "demo-instance" {
  name                  = "${var.prefix}-vm"
  location              = var.location
  resource_group_name   = azurerm_resource_group.demo.name
  network_interface_ids = [azurerm_network_interface.demo-instance.id]
  vm_size               = "Standard_B1s"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "demo-instance"
    admin_username = "demo"
    admin_password = "StrongP@ssword123!"  
  }

  os_profile_linux_config {
    disable_password_authentication = false  
  }
}

/*
Vytvorte sieťové rozhranie s názvom, ktorý začína prefixom definovaným v premennej a končí "-instance1"
Umiestnite ho v rovnakej lokácii ako resource group
Prepojte ho s vytvorenou resource group
Nastavte konfiguráciu IP:

Názov: "instance1"
Prepojte s vytvorenou podsieťou "demo-internal-1"
Nastavte dynamické prideľovanie privátnej IP adresy
Prepojte s vytvorenou verejnou IP adresou
*/
resource "azurerm_network_interface" "demo-instance" {
  name                = "${var.prefix}-instance1"
  location            = var.location
  resource_group_name = azurerm_resource_group.demo.name

  ip_configuration {
    name                          = "instance1"
    subnet_id                     = azurerm_subnet.demo-internal-1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.demo-instance.id
  }
}

/*
Vytvorte asociáciu medzi sieťovým rozhraním a bezpečnostnou skupinou
Prepojte ju s vytvoreným sieťovým rozhraním
Prepojte ju s vytvorenou bezpečnostnou skupinou "allow-ssh"
*/
resource "azurerm_network_interface_security_group_association" "demo-instance-association" {
  network_interface_id      = azurerm_network_interface.demo-instance.id
  network_security_group_id = azurerm_network_security_group.allow-ssh.id
}

/*
Vytvorte verejnú IP adresu s názvom "instance1-public-ip"
Umiestnite ju v rovnakej lokácii ako resource group
Prepojte ju s vytvorenou resource group
Nastavte statickú metódu alokácie
*/
resource "azurerm_public_ip" "demo-instance" {
  name                = "instance1-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.demo.name
  allocation_method   = "Static"
}

/*
Tento dátový zdroj získava informácie o vytvorenej verejnej IP adrese, aby bolo možné použiť jej hodnotu v ďalších zdrojoch.

Čo treba spraviť:
Vytvorte dátový zdroj, ktorý referencuje verejnú IP adresu s názvom "instance1-public-ip"
Prepojte ho s vytvorenou resource group
Nastavte závislosti od vytvorenia verejnej IP adresy a virtuálneho stroja

*/
data "azurerm_public_ip" "public_ip" {
  name                = "instance1-public-ip"
  resource_group_name = azurerm_resource_group.demo.name
  depends_on          = [azurerm_public_ip.demo-instance, azurerm_virtual_machine.demo-instance]
}