terraform {
  source = "tfr:///Azure/vnet/azurerm//?version=2.6.0"
}

include {
  path = find_in_parent_folders()
}

dependencies {
  paths = ["../../global/resource_groups"]
}

dependency "resource_groups" {
  config_path = "../../global/resource_groups"

  mock_outputs = {
    vnet_resource_group_name = "rg-terragrunt-mock-001"
  }
  mock_outputs_merge_with_state = true
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  environment = local.env_vars.locals.environment

  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  location = local.region_vars.locals.location
}

inputs = {
  vnet_name           = "vnet-spoke-${local.environment}-${local.location}-001"
  resource_group_name = dependency.resource_groups.outputs.vnet_resource_group_name
  address_space       = ["10.0.0.0/16"]
  subnet_prefixes     = ["10.0.1.0/26", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
  subnet_names        = ["AzureBastionSubnet", "Management", "Tools", "Workloads"]
  location            = local.location

  tags = {
    environment = local.environment
  }
}