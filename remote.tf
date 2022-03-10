## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

data "template_file" "ror_bootstrap_template" {
  count    = var.numberOfNodes
  template = file("./scripts/ror_bootstrap.sh")

  vars = {
    db_name              = var.mysql_db_name
    db_user_name         = var.mysql_db_system_admin_username
    db_user_password     = var.mysql_db_system_admin_password
    db_server_ip_address = oci_mysql_mysql_db_system.mds01_mysql_db_system.ip_address
    ror_host          = "ror-server-${count.index}"
    ruby_version       = var.ruby_version
    ruby_major_release = split(".", var.ruby_version)[0]
  }
}

data "template_file" "database_yml" {
  template = file("./ror/database.yml")

  vars = {
    db_user_name         = var.mysql_db_system_admin_username
    db_user_password     = var.mysql_db_system_admin_password
    db_server_ip_address = oci_mysql_mysql_db_system.mds01_mysql_db_system.ip_address
  }
}


data "template_file" "start_rails" {
  template = file("./scripts/start_rails.sh")

  vars = {
    db_user_name         = var.mysql_db_system_admin_username
    db_user_password     = var.mysql_db_system_admin_password
    db_server_ip_address = oci_mysql_mysql_db_system.mds01_mysql_db_system.ip_address
  }
}


data "template_file" "shell_script_service" {
  template = file("./scripts/shellscript.service")

  vars = {
    db_user_name         = var.mysql_db_system_admin_username
    db_user_password     = var.mysql_db_system_admin_password
    db_server_ip_address = oci_mysql_mysql_db_system.mds01_mysql_db_system.ip_address
  }
}






resource "null_resource" "ror_bootstrap" {
  count      = var.numberOfNodes
  depends_on = [oci_core_instance.ror-server]


  provisioner "file" {
    connection {
      type                = "ssh"
      user                = "ubuntu"
      host                = data.oci_core_vnic.ror-server_primaryvnic[count.index].private_ip_address
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      script_path         = "/home/ubuntu/myssh.sh"
      agent               = false
      timeout             = "1m"
      bastion_host        = var.use_bastion_service ? "host.bastion.${var.region}.oci.oraclecloud.com" : oci_core_instance.bastion_instance[0].public_ip
      bastion_port        = "22"
      bastion_user        = var.use_bastion_service ? oci_bastion_session.ssh_via_bastion_service[count.index].id : "ubuntu"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }

    content     = data.template_file.shell_script_service.rendered
    destination = "/home/ubuntu/shellscript.service"
  }



provisioner "file" {
    connection {
      type                = "ssh"
      user                = "ubuntu"
      host                = data.oci_core_vnic.ror-server_primaryvnic[count.index].private_ip_address
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      script_path         = "/home/ubuntu/myssh.sh"
      agent               = false
      timeout             = "1m"
      bastion_host        = var.use_bastion_service ? "host.bastion.${var.region}.oci.oraclecloud.com" : oci_core_instance.bastion_instance[0].public_ip
      bastion_port        = "22"
      bastion_user        = var.use_bastion_service ? oci_bastion_session.ssh_via_bastion_service[count.index].id : "ubuntu"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }

    content     = data.template_file.start_rails.rendered 
    destination = "/home/ubuntu/start_rails.sh"
  }


  provisioner "file" {
    connection {
      type                = "ssh"
      user                = "ubuntu"
      host                = data.oci_core_vnic.ror-server_primaryvnic[count.index].private_ip_address
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      script_path         = "/home/ubuntu/myssh.sh"
      agent               = false
      timeout             = "1m"
      bastion_host        = var.use_bastion_service ? "host.bastion.${var.region}.oci.oraclecloud.com" : oci_core_instance.bastion_instance[0].public_ip
      bastion_port        = "22"
      bastion_user        = var.use_bastion_service ? oci_bastion_session.ssh_via_bastion_service[count.index].id : "ubuntu"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }

    content     = data.template_file.ror_bootstrap_template[count.index].rendered 
    destination = "/home/ubuntu/ror_bootstrap.sh"
  }


  provisioner "file" {
    connection {
      type                = "ssh"
      user                = "ubuntu"
      host                = data.oci_core_vnic.ror-server_primaryvnic[count.index].private_ip_address
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      script_path         = "/home/ubuntu/myssh.sh"
      agent               = false
      timeout             = "1m"
      bastion_host        = var.use_bastion_service ? "host.bastion.${var.region}.oci.oraclecloud.com" : oci_core_instance.bastion_instance[0].public_ip
      bastion_port        = "22"
      bastion_user        = var.use_bastion_service ? oci_bastion_session.ssh_via_bastion_service[count.index].id : "ubuntu"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }

    content     = data.template_file.database_yml.rendered
    destination = "/home/ubuntu/database.yml"
  }
  
  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "ubuntu"
      host                = data.oci_core_vnic.ror-server_primaryvnic[count.index].private_ip_address
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      script_path         = "/home/ubuntu/myssh.sh"
      agent               = false
      timeout             = "15m"
      bastion_host        = var.use_bastion_service ? "host.bastion.${var.region}.oci.oraclecloud.com" : oci_core_instance.bastion_instance[0].public_ip
      bastion_port        = "22"
      bastion_user        = var.use_bastion_service ? oci_bastion_session.ssh_via_bastion_service[count.index].id : "ubuntu"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem

    }
    inline = [
      "chmod +x /home/ubuntu/ror_bootstrap.sh",
      "sudo /home/ubuntu/ror_bootstrap.sh",
      "sleep 10" 
    ]
  }
}




