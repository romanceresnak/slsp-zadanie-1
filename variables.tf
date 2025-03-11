/*
Vytvorte premennú s názvom "location"
Nastavte jej typ na string (textový reťazec)
Nastavte predvolenú hodnotu na "northeurope"
Táto premenná bude použitá pri definovaní lokácie pre vytvárané zdroje
*/
variable "location" {
  type    = string
  default = "northeurope"
}

/*
Vytvorte premennú s názvom "failover_location"
Nastavte jej typ na string (textový reťazec)
Nastavte predvolenú hodnotu na "uksouth"
Táto premenná sa typicky používa pre služby s vysokou dostupnosťou, 
ako je Cosmos DB
*/
variable "failover_location" {
  type    = string
  default = "uksouth"
}

/*


Vytvorte premennú s názvom "prefix"
Nastavte jej typ na string (textový reťazec)
Nastavte predvolenú hodnotu na "demo"
Táto premenná sa používa pri pomenovaní zdrojov pre 
konzistentnosť a jednoduchšiu identifikáciu
*/
variable "prefix" {
  type    = string
  default = "demo"
}

/*
Vytvorte premennú s názvom "private-cidr"
Nastavte jej typ na string (textový reťazec)
Nastavte predvolenú hodnotu na "10.0.0.0/24"
Táto premenná sa používa pri definovaní adresných 
priestorov pre virtuálne siete a podsiete
*/
variable "private-cidr" {
  type    = string
  default = "10.0.0.0/24"
}