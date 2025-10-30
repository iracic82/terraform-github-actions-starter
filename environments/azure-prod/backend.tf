terraform {
  backend "azurerm" {
    # UPDATE THESE VALUES after running the backend setup script
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstateXXXXX"  # Must be globally unique
    container_name       = "tfstate"
    key                  = "azure-prod.terraform.tfstate"
  }
}
