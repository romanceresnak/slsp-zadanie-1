/*
Vytvorte virtuálnu sieť s názvom, ktorý začína prefixom definovaným v premennej a končí "-network"
Nastavte ju v lokácii definovanej pomocou premennej "location"
Prepojte ju s existujúcou resource group "demo"
Nastavte adresný priestor na "10.0.0.0/16"
*/
resource "azurerm_virtual_network" "demo" {
  name                = "${var.prefix}-network"
  location            = var.location
  resource_group_name = azurerm_resource_group.demo.name
  address_space       = ["10.0.0.0/16"]
}

/*
Vytvorte podsieť s názvom, ktorý začína prefixom definovaným 
v premennej a končí "-internal-1"
Prepojiť ju so správnou resource group
Umiestniť ju do vytvorenej virtuálnej siete
Nastaviť adresný priestor na "10.0.0.0/24"
Povoliť service endpoint pre Microsoft.AzureCosmosDB
*/
resource "azurerm_subnet" "demo-internal-1" {
  name                 = "${var.prefix}-internal-1"
  resource_group_name  = azurerm_resource_group.demo.name
  virtual_network_name = azurerm_virtual_network.demo.name
  address_prefixes     = ["10.0.0.0/24"]
  service_endpoints    = ["Microsoft.AzureCosmosDB"]
}

/*
Vytvorte bezpečnostnú skupinu s názvom, ktorý začína prefixom definovaným v premennej a končí "-allow-ssh"
Nastavte ju v rovnakej lokácii ako virtuálnu sieť
Prepojte ju s existujúcou resource group "demo"
Pridajte bezpečnostné pravidlo s nasledujúcimi vlastnosťami:

Názov: "SSH"
Priorita: 1001
Smer: "Inbound" (prichádzajúce pripojenia)
Prístup: "Deny" (zamietnuť)
Protokol: "Tcp"
Zdrojový port: všetky ("*")
Cieľový port: 22
Zdrojová adresa: všetky ("*")
Cieľová adresa: všetky ("*")
*/
resource "azurerm_network_security_group" "allow-ssh" {
  name                = "${var.prefix}-allow-ssh"
  location            = var.location
  resource_group_name = azurerm_resource_group.demo.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Deny" 
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}