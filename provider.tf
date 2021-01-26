terraform {
  required_providers {
    azuread = {
      source  = "azuread"
      version = "1.2.2"
    }
  }
}

provider "azuread" {
}
