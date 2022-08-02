## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Get list of availability domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

# Get the latest Oracle Linux image
data "oci_core_images" "InstanceImageOCID" {
  compartment_id           = var.compartment_ocid
  operating_system         = var.instance_os
  operating_system_version = var.linux_os_version
  shape                    = var.InstanceShape

  filter {
    name   = "display_name"
    values = ["^.*Ubuntu[^G]*$"]
    regex  = true
  }
}

#Get list of MySQL configuration
data "oci_mysql_mysql_configurations" "mds_mysql_configurations" {
  compartment_id = var.compartment_ocid
  type           = ["DEFAULT"]
  shape_name     = var.mysql_shape_name
}

data "oci_core_vnic_attachments" "ror-server_primaryvnic_attach" {
  count               = var.numberOfNodes
  availability_domain = var.availablity_domain_name
  compartment_id      = var.compartment_ocid
  instance_id         = oci_core_instance.ror-server[count.index].id
}

data "oci_core_vnic" "ror-server_primaryvnic" {
  count   = var.numberOfNodes
  vnic_id = data.oci_core_vnic_attachments.ror-server_primaryvnic_attach[count.index].vnic_attachments.0.vnic_id
}

