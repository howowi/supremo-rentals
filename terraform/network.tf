## ------- Virtual Cloud Network -------- ##

resource oci_core_vcn oke1-vcn {
  cidr_blocks = [
    var.oke_vcn_cidr_blocks,
  ]
  compartment_id = var.compartment_ocid
  display_name = "${var.resource_naming_prefix}-vcn"
  dns_label    = "okecluster1"
}

## ------- Internet Gateway -------- ##

resource oci_core_internet_gateway oke1-igw {
  compartment_id = var.compartment_ocid
  display_name = "${var.resource_naming_prefix}-igw"
  vcn_id = oci_core_vcn.oke1-vcn.id
}

## ------- Service Gateway ------- ##
resource oci_core_service_gateway oke1-sgw {
  compartment_id = var.compartment_ocid
  display_name = "${var.resource_naming_prefix}-sgw"
  services {
    service_id = data.oci_core_services.all_services.services.0.id
  }
  vcn_id = oci_core_vcn.oke1-vcn.id
}

## ------- NAT Gateway ------- ##
resource oci_core_nat_gateway oke1-ngw {
  compartment_id = var.compartment_ocid
  display_name = "${var.resource_naming_prefix}-ngw"
  vcn_id       = oci_core_vcn.oke1-vcn.id
}

## ------- Default Public Route Table ------- ##

resource oci_core_default_route_table public-routetable {
  compartment_id = var.compartment_ocid
  display_name = "Default Route Table for public subnet"
  manage_default_resource_id = oci_core_vcn.oke1-vcn.default_route_table_id
  route_rules {
    description       = "traffic to/from internet"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.oke1-igw.id
  }
}

## ------- Private Route Table ------- ##
resource oci_core_route_table private-routetable {
  compartment_id = var.compartment_ocid
  display_name = "Route Table for private subnet"
  route_rules {
    description       = "traffic to the internet"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.oke1-ngw.id
  }
  route_rules {
    description       = "traffic to OCI services"
    destination       = data.oci_core_services.all_services.services.0.cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.oke1-sgw.id
  }
  vcn_id = oci_core_vcn.oke1-vcn.id
}

## ----- OKE Subnets and Security Lists ----- ##

resource oci_core_subnet oke1-k8sapiendpoint-subnet {
  cidr_block = var.oke_k8sapiendpoint_subnet_cidr_block
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_vcn.oke1-vcn.id
  display_name = "${var.resource_naming_prefix}-oke1-k8sapiendpoint-subnet"
  route_table_id =  oci_core_default_route_table.public-routetable.id
  security_list_ids = [oci_core_security_list.oke1-k8sapiendpoint-sl.id]
}

resource oci_core_subnet oke1-service_lb-subnet {
  cidr_block = var.oke_service_lb_subnet_cidr_block
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_vcn.oke1-vcn.id
  display_name = "${var.resource_naming_prefix}-oke1-service_lb-subnet"
  route_table_id = oci_core_default_route_table.public-routetable.id
  security_list_ids = [oci_core_security_list.oke1-service_lb-sl.id]
}

resource oci_core_subnet oke1-nodepool-subnet {
  cidr_block = var.oke_nodepool_cidr_block
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_vcn.oke1-vcn.id
  display_name = "${var.resource_naming_prefix}-oke1-nodepool-subnet"
  prohibit_public_ip_on_vnic = "true"
  route_table_id = oci_core_route_table.private-routetable.id
  security_list_ids = [oci_core_security_list.oke1-nodepool-sl.id]
}

resource oci_core_security_list oke1-k8sapiendpoint-sl {
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_vcn.oke1-vcn.id
  display_name = "${var.resource_naming_prefix}-oke1-k8sapiendpoint-sl"
  
  egress_security_rules {
		description = "Allow Kubernetes Control Plane to communicate with OKE"
		destination = data.oci_core_services.all_services.services.0.cidr_block
		destination_type = "SERVICE_CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
	}
	egress_security_rules {
		description = "All traffic to worker nodes"
		destination = var.oke_nodepool_cidr_block
		destination_type = "CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
	}
	egress_security_rules {
		description = "Path discovery"
		destination = var.oke_nodepool_cidr_block
		destination_type = "CIDR_BLOCK"
		icmp_options {
			code = "4"
			type = "3"
		}
		protocol = "1"
		stateless = "false"
	}
	ingress_security_rules {
		description = "External access to Kubernetes API endpoint"
		protocol = "6"
		source = "0.0.0.0/0"
		stateless = "false"
	}
	ingress_security_rules {
		description = "Kubernetes worker to Kubernetes API endpoint communication"
		protocol = "6"
		source = var.oke_nodepool_cidr_block
		stateless = "false"
	}
	ingress_security_rules {
		description = "Kubernetes worker to control plane communication"
		protocol = "6"
		source = var.oke_nodepool_cidr_block
		stateless = "false"
	}
	ingress_security_rules {
		description = "Path discovery"
		icmp_options {
			code = "4"
			type = "3"
		}
		protocol = "1"
		source = var.oke_nodepool_cidr_block
		stateless = "false"
	}
}

resource oci_core_security_list oke1-service_lb-sl {
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_vcn.oke1-vcn.id
  display_name = "${var.resource_naming_prefix}-oke1-service_lb-sl"

  egress_security_rules {
	  description = "Allow all traffic"
	  destination = "0.0.0.0/0"
	  protocol = "all"
	  stateless = "false"
  }

  ingress_security_rules {
	  description = "Allow all traffic"
	  source = "0.0.0.0/0"
	  protocol = "all"
	  stateless = "false"
  }
}

resource oci_core_security_list oke1-nodepool-sl {
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_vcn.oke1-vcn.id
  display_name = "${var.resource_naming_prefix}-oke1-nodepool-sl"

  egress_security_rules {
		description = "Allow pods on one worker node to communicate with pods on other worker nodes"
		destination = var.oke_nodepool_cidr_block
		destination_type = "CIDR_BLOCK"
		protocol = "all"
		stateless = "false"
	}
	egress_security_rules {
		description = "Access to Kubernetes API Endpoint"
		destination = oci_core_subnet.oke1-k8sapiendpoint-subnet.cidr_block
		destination_type = "CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
    tcp_options {
      max = "6443"
      min = "6443"
      source_port_range {
        max = "65535"
        min = "1"
      }
    }
	}
	egress_security_rules {
		description = "Kubernetes worker to control plane communication"
		destination = oci_core_subnet.oke1-k8sapiendpoint-subnet.cidr_block
		destination_type = "CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
    tcp_options {
      max = "12250"
      min = "12250"
      source_port_range {
        max = "65535"
        min = "1"
      }
    }
	}
	egress_security_rules {
		description = "Path discovery"
		destination = oci_core_subnet.oke1-k8sapiendpoint-subnet.cidr_block
		destination_type = "CIDR_BLOCK"
		icmp_options {
			code = "4"
			type = "3"
		}
		protocol = "1"
		stateless = "false"
	}
	egress_security_rules {
		description = "Allow nodes to communicate with OKE to ensure correct start-up and continued functioning"
		destination = data.oci_core_services.all_services.services.0.cidr_block
		destination_type = "SERVICE_CIDR_BLOCK"
		protocol = "6"
		stateless = "false"
    tcp_options {
      max = "443"
      min = "443"
      source_port_range {
        max = "65535"
        min = "1"
      }
    }
	}
	egress_security_rules {
		description = "ICMP Access from Kubernetes Control Plane"
		destination = "0.0.0.0/0"
		destination_type = "CIDR_BLOCK"
		icmp_options {
			code = "4"
			type = "3"
		}
		protocol = "1"
		stateless = "false"
	}
	egress_security_rules {
		description = "Worker Nodes access to Internet"
		destination = "0.0.0.0/0"
		destination_type = "CIDR_BLOCK"
		protocol = "all"
		stateless = "false"
	}
	ingress_security_rules {
		description = "Allow pods on one worker node to communicate with pods on other worker nodes"
		protocol = "all"
		source = var.oke_nodepool_cidr_block
		stateless = "false"
	}
	ingress_security_rules {
		description = "Path discovery"
		icmp_options {
			code = "4"
			type = "3"
		}
		protocol = "1"
		source = oci_core_subnet.oke1-k8sapiendpoint-subnet.cidr_block
		stateless = "false"
	}
	ingress_security_rules {
		description = "TCP access from Kubernetes Control Plane"
		protocol = "6"
		source = oci_core_subnet.oke1-k8sapiendpoint-subnet.cidr_block
		stateless = "false"
	}
	ingress_security_rules {
		description = "Inbound SSH traffic to worker nodes"
		protocol = "6"
		source = "0.0.0.0/0"
		stateless = "false"
    tcp_options {
      max = "22"
      min = "22"
      source_port_range {
        max = "65535"
        min = "1"
      }
    }
	}
}