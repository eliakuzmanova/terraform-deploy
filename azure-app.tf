terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.89.0"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

resource "azurerm_resource_group" "contact_book_RG" {
  name     = "ContactBookRG${random_integer.ri.result}"
  location = "Poland Central"
}

resource "azurerm_service_plan" "contact_book_service_plan" {
  name                = "contact-book_${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.contact_book_RG.name
  location            = azurerm_resource_group.contact_book_RG.location
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "contact_book_web_app" {
  name                = "contact-book-app-${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.contact_book_RG.name
  location            = azurerm_service_plan.contact_book_service_plan.location
  service_plan_id     = azurerm_service_plan.contact_book_service_plan.id

  site_config {
    application_stack {
      node_version = "16-lts"
    }
    always_on = false
  }
}

resource "azurerm_app_service_source_control" "contact_book_SC" {
  app_id                 = azurerm_linux_web_app.contact_book_web_app.id
  repo_url               = "https://github.com/nakov/ContactBook"
  branch                 = "master"
  use_manual_integration = true
}