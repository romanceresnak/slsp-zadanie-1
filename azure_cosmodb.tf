/*
Vytvorte zdroj pre generovanie náhodného reťazca s dĺžkou 5 znakov
Nastavte, aby neobsahoval veľké písmená (upper = false)
Nastavte, aby obsahoval malé písmená (lower = true)
Nastavte, aby obsahoval číslice (numeric = true)
Nastavte, aby neobsahoval špeciálne znaky (special = false)
*/
resource "random_string" "random-name" {
  length  = 5
  upper   = false
  lower   = true
  numeric = true
  special = false
}

/*
Vytvorte Cosmos DB účet s názvom, ktorý kombinuje "training-cosmos-db-" a vygenerovaný náhodný reťazec
Umiestnite ho v rovnakej lokácii ako resource group
Prepojte ho s existujúcou resource group "demo"
Nastavte typ ponuky (offer_type) na "Standard"
Nastavte druh (kind) na "MongoDB"
Nastavte verziu MongoDB servera na "7.0"
Povoľte automatický failover
Povoľte filtrovanie virtuálnej siete
Pridajte pravidlo virtuálnej siete pre podsieť "demo-internal-1"
Nastavte politiku konzistencie:

Úroveň konzistencie (consistency_level): "BoundedStaleness"
Maximálny interval v sekundách: 300
Maximálny prefix zastaranosti: 100000


Pridajte dve geografické lokácie:

Primárna (failover_priority = 0): rovnaká ako resource group
Sekundárna (failover_priority = 1): definovaná v premennej failover_location
*/
resource "azurerm_cosmosdb_account" "db" {
  name                = "training-cosmos-db-${random_string.random-name.result}"
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name
  offer_type          = "Standard"
  kind                = "MongoDB"

  mongo_server_version = "7.0"

  automatic_failover_enabled = true

  is_virtual_network_filter_enabled = true

  virtual_network_rule {
    id = azurerm_subnet.demo-internal-1.id
  }

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }

  geo_location {
    location          = var.failover_location
    failover_priority = 1
  }

  geo_location {
    location          = azurerm_resource_group.demo.location
    failover_priority = 0
  }
}

/*
Vytvorte MongoDB databázu s názvom "trainig-cosmos-mongo-db"
Prepojte ju s existujúcou resource group "demo"
Prepojte ju s vytvoreným Cosmos DB účtom
*/
resource "azurerm_cosmosdb_mongo_database" "mongo-example-database" {
  name                = "trainig-cosmos-mongo-db"
  resource_group_name = azurerm_resource_group.demo.name
  account_name        = azurerm_cosmosdb_account.db.name
}

/*
Vytvorte MongoDB kolekciu s názvom "training-cosmos-mongo-db"
Prepojte ju s existujúcou resource group "demo"
Prepojte ju s vytvoreným Cosmos DB účtom a MongoDB databázou
Nastavte predvolený TTL (time-to-live) na 777 sekúnd
Nastavte kľúč shardovania (shard_key) na "uniqueKey"
Pridajte tri indexy:

Index pre pole "aKey" (neunikátny)
Unikátny index pre pole "uniqueKey"
Unikátny index pre pole "_id"
*/
resource "azurerm_cosmosdb_mongo_collection" "mongo-example-collection" {
  name                = "training-cosmos-mongo-db"
  resource_group_name = azurerm_resource_group.demo.name
  account_name        = azurerm_cosmosdb_account.db.name
  database_name       = azurerm_cosmosdb_mongo_database.mongo-example-database.name

  default_ttl_seconds = "777"
  shard_key           = "uniqueKey"

  index {
    keys   = ["aKey"]
    unique = false
  }

  index {
    keys   = ["uniqueKey"]
    unique = true
  }

  index {
    keys   = ["_id"]
    unique = true
  }
}

