## Copyright (c) 2022, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {
  defined_tags = module.policies.predefined_tags
  # declare a local for defined tags to conceal from the rest of the module how we're creating them
  random_id = module.policies.random_id
  # conceal from the rest of the module how this value is setup
}
module "policies" {
  #source = "../terraform-oci-arch-policies"
  source                        = "github.com/oracle-devrel/terraform-oci-arch-policies"
  activate_policies_for_service = ["Network"]
  tenancy_ocid                  = var.tenancy_ocid
  compartment_ocid              = var.compartment_ocid
  region_name                   = var.region
  tag_namespace                 = "deploy-ror-mysql-"
  release                       = var.release
}
