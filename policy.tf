data "intersight_organization_organization" "org" {
    name = var.organization
}

resource "intersight_hyperflex_vcenter_config_policy" "hyperflex_vcenter_config_policy1" {
  hostname    = "vcenter.${var.dns_domain_suffix}"
  username    = "administrator@${var.dns_domain_suffix}"
  password    = var.password
  data_center = var.env
  sso_url     = ""
  organization {
    object_type = "organization.Organization"
    moid        = data.intersight_organization_organization.org.results[0].moid
  }
  name = "${var.env}_HyperFlex_vCenter_Policy"
  description = "Created by Terraform"
}

resource "intersight_hyperflex_local_credential_policy" "hyperflex_local_credential_policy1" {
  hxdp_root_pwd               = var.password
  hypervisor_admin            = "root"
  hypervisor_admin_pwd        = var.password
  factory_hypervisor_password = false
  organization {
    object_type = "organization.Organization"
    moid        = data.intersight_organization_organization.org.results[0].moid
  }
  name = "${var.env}_Hyperflex_local_credential_policy"
  description = "Created by Terraform"
}

resource "intersight_hyperflex_sys_config_policy" "hyperflex_sys_config_policy1" {
  dns_servers     = ["${var.subnet_str}.3"]
  ntp_servers     = ["${var.subnet_str}.3"]
  timezone        = "Europe/Amsterdam"
  dns_domain_name = var.dns_domain_suffix
  organization {
    object_type = "organization.Organization"
    moid        = data.intersight_organization_organization.org.results[0].moid
  }
  name = "${var.env}_HyperFlex_System_Config_Policy"
  description = "Created by Terraform"
}

resource "intersight_hyperflex_cluster_storage_policy" "hyperflex_cluster_storage_policy1" {
  disk_partition_cleanup = true
  vdi_optimization       = true
  organization {
    object_type = "organization.Organization"
    moid        = data.intersight_organization_organization.org.results[0].moid
  }
  name = "${var.env}_HyperFlex_Storage_Cluster_Policy"
  description = "Created by Terraform"
}

resource "intersight_hyperflex_cluster_network_policy" "hyperflex_cluster_network_policy1" {
  mgmt_vlan {
    name    = "hx-inband-mgmt"
    vlan_id = 10
}
  jumbo_frame  = true
  uplink_speed = "default"
  vm_migration_vlan {
    name = "HX-Migration"
    vlan_id = 12
  }

  vm_network_vlans = [
    for vlan in var.vm_vlans :
    {
        name = "HX-${var.env}-VM-VLAN-${tostring(vlan)}"
        vlan_id = vlan
        class_id = "hyperflex.NamedVlan"
        object_type = "hyperflex.NamedVlan"
        additional_properties = ""
    }
  ]

  mac_prefix_range {
    end_addr   = "00:25:B5:D5"
    start_addr = "00:25:B5:D5"
  }
  kvm_ip_range {
    start_addr = "${var.subnet_str}.200"
    end_addr = "${var.subnet_str}.220"
    gateway = "${var.subnet_str}.1"
    netmask = "255.255.255.0"
  }
  organization {
    object_type = "organization.Organization"
    moid        = data.intersight_organization_organization.org.results[0].moid
  }
  name = "${var.env}_HyperFlex_Cluster_Network_Policy"
  description = "Created by Terraform"
}

