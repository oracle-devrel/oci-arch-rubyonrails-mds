## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl


resource "time_sleep" "wait_2min" {
  depends_on = [
    oci_core_instance.ror-server
  ]
  create_duration = "240s"
}



resource "oci_bastion_bastion" "bastion-service" {

  depends_on = [
    time_sleep.wait_2min
  ]
  count                        = var.use_bastion_service ? 1 : 0
  bastion_type                 = "STANDARD"
  compartment_id               = var.compartment_ocid
  target_subnet_id             = oci_core_subnet.vcn01_subnet_pub02.id
  client_cidr_block_allow_list = ["0.0.0.0/0"]
  defined_tags                 = local.defined_tags
  name                         = "BastionService${local.random_id}"
  max_session_ttl_in_seconds   = 1800
}

resource "oci_bastion_session" "ssh_via_bastion_service" {
  depends_on = [oci_core_instance.ror-server,
    oci_core_nat_gateway.vcn01_nat_gateway,
    oci_core_route_table_attachment.vcn01_subnet_app01_route_table_attachment,
    oci_core_route_table.vnc01_nat_route_table,
    oci_core_network_security_group.SSHSecurityGroup,
    oci_core_network_security_group_security_rule.SSHSecurityEgressGroupRule,
    oci_core_network_security_group_security_rule.SSHSecurityIngressGroupRules
  ]
  lifecycle {
    precondition {
      condition     = (oci_core_instance.ror-server[count.index].state == "RUNNING")
      error_message = "RoR server not yet active"
    }
  }

  count      = var.use_bastion_service ? var.numberOfNodes : 0
  bastion_id = oci_bastion_bastion.bastion-service[0].id

  key_details {
    public_key_content = tls_private_key.public_private_key_pair.public_key_openssh
  }
  target_resource_details {
    session_type       = "MANAGED_SSH"
    target_resource_id = oci_core_instance.ror-server[count.index].id

    #Optional
    target_resource_operating_system_user_name = "ubuntu"
    target_resource_port                       = 22
    target_resource_private_ip_address         = oci_core_instance.ror-server[count.index].private_ip
  }

  display_name           = "${local.namespace_name}ssh_via_bastion_service"
  key_type               = "PUB"
  session_ttl_in_seconds = 1800
}


resource "oci_core_instance" "bastion_instance" {
  count               = var.use_bastion_service ? 0 : 1
  availability_domain = var.availablity_domain_name == "" ? data.oci_identity_availability_domains.ADs.availability_domains[var.availablity_domain_number]["name"] : var.availablity_domain_name
  compartment_id      = var.compartment_ocid
  display_name        = "${local.namespace_name}BastionVM"
  shape               = var.InstanceShape

  dynamic "shape_config" {
    for_each = local.is_flexible_node_shape ? [1] : []
    content {
      memory_in_gbs = var.InstanceFlexShapeMemory
      ocpus         = var.InstanceFlexShapeOCPUS
    }
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.vcn01_subnet_pub02.id
    display_name     = "${local.namespace_name}primaryvnic"
    assign_public_ip = true
    nsg_ids          = [oci_core_network_security_group.SSHSecurityGroup.id]
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.InstanceImageOCID.images[0].id
    boot_volume_size_in_gbs = "50"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = data.cloudinit_config.cloud_init.rendered
  }

  defined_tags = local.defined_tags
}


