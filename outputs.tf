/*
Vytvorte výstupnú premennú s názvom "connection_strings"
Nastavte jej hodnotu na pripojovací reťazec z vytvoreného Cosmos DB účtu
Použite funkciu nonsensitive() na odstránenie označenia citlivých údajov, aby bolo možné hodnotu zobraziť v Terraform výstupoch
Výstup referencuje existujúci zdroj azurerm_cosmosdb_account s názvom "db"
*/

output "connection_strings" {
  value = nonsensitive(azurerm_cosmosdb_account.db.primary_mongodb_connection_string)
}

/*
Vytvorte výstupnú premennú s názvom "demo_instance_public_ip"
Pridajte popis, ktorý vysvetľuje, že ide o IP adresu priradenú zdroju
Nastavte hodnotu výstupu na IP adresu získanú z dátového zdroja "public_ip"
Výstup referencuje existujúci dátový zdroj data.azurerm_public_ip s názvom "public_ip"
*/
output "demo_instance_public_ip" {
  description = "The actual ip address allocated for the resource."
  value       = data.azurerm_public_ip.public_ip.ip_address
}