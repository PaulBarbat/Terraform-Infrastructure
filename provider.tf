# provider.tf
# configures AWS provider for terraform
# Configures the region in which all resources will be located
# TODO change to a variable
# TODO enforce tags
# TODO test out profiles
# Declares which provider (cloud) Terraform will use for this configuration.
# provider.tf
provider "aws" {
  region = var.region
}
