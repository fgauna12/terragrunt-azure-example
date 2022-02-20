# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Automatically load subscription variables
  subscription_vars = read_terragrunt_config(find_in_parent_folders("subscription.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  
  location          = local.region_vars.locals.location
  environment       = local.environment_vars.locals.environment
  subscription_id   = local.subscription_vars.locals.subscription_id
}

# Generate Azure providers
generate "versions" {
  path      = "versions_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    terraform {
      required_providers {
        azurerm = {
          source = "hashicorp/azurerm"
          version = "2.95.0"
        }
        azuread = {
            source = "hashicorp/azuread"
            version = "2.18.0"
        }
      }
    }

    provider "azurerm" {
        features {}
        subscription_id = "${local.subscription_id}"
    }

    provider "azuread" {
    }
EOF
}

remote_state {
    backend = "azurerm"
    config = {
        subscription_id = "${local.subscription_id}"
        key = "${path_relative_to_include()}/terraform.tfstate"
        resource_group_name = "rg-terragrunt-example-001"
        storage_account_name = "stterragruntexample001"
        container_name = "environment-states"
    }
    generate = {
        path      = "backend.tf"
        if_exists = "overwrite_terragrunt"
    }
}

# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.subscription_vars.locals,
  local.region_vars.locals,
  local.environment_vars.locals
)