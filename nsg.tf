## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# SSHSecurityGroup

resource "oci_core_network_security_group" "SSHSecurityGroup" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn01.id
  display_name   = "${local.namespace_name}Bastion_NSG"
  defined_tags   = local.defined_tags
}

# SSHSecurityGroup Rules - EGRESS

resource "oci_core_network_security_group_security_rule" "SSHSecurityEgressGroupRule" {
  network_security_group_id = oci_core_network_security_group.SSHSecurityGroup.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

# SSHSecurityGroup Rules - INGRES

resource "oci_core_network_security_group_security_rule" "SSHSecurityIngressGroupRules" {
  network_security_group_id = oci_core_network_security_group.SSHSecurityGroup.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 22
      min = 22
    }
  }
}

# LBSecurityGroup

resource "oci_core_network_security_group" "LBSecurityGroup" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn01.id
  display_name   = "${local.namespace_name}LB_NSG"
  defined_tags   = local.defined_tags
}


# LBSecurityGroup Rules - EGRESS

resource "oci_core_network_security_group_security_rule" "LBSecurityEgressInternetGroupRule" {
  network_security_group_id = oci_core_network_security_group.LBSecurityGroup.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

# LBSecurityGroup Rules - INGRESS

resource "oci_core_network_security_group_security_rule" "LBSecurityIngressGroupRules_TCP80" {
  network_security_group_id = oci_core_network_security_group.LBSecurityGroup.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 80
      min = 80
    }
  }
}

resource "oci_core_network_security_group_security_rule" "LBSecurityIngressGroupRules_TCP443" {
  network_security_group_id = oci_core_network_security_group.LBSecurityGroup.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 443
      min = 443
    }
  }
}

# APPSecurityGroup

resource "oci_core_network_security_group" "APPSecurityGroup" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn01.id
  display_name   = "APP_NSG"
  defined_tags   = local.defined_tags
}

# EGRESS Rules - APPSecurityGroup 
resource "oci_core_network_security_group_security_rule" "APPSecurityEgressGroupRules" {
  network_security_group_id = oci_core_network_security_group.APPSecurityGroup.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

# INGRESS Rules - APPSecurityGroup 

resource "oci_core_network_security_group_security_rule" "APPSecurityIngressGroupRules" {
  network_security_group_id = oci_core_network_security_group.APPSecurityGroup.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 8080
      min = 8080
    }
  }
}


