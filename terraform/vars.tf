terraform {
  required_providers {
    oci = {
      source  = "hashicorp/oci"
      version = ">= 5.15.0"
    }
  }
  required_version = ">= 1.0"
}

provider "oci" {
  region          = var.region
  tenancy_ocid    = var.tenancy_ocid
}

variable "compartment_ocid" {
  description = "Please provide compartment OCID."
  type        = string
}

variable "tenancy_ocid" {
  description = "Please provide tenancy OCID."
  type = string
}

variable "region" {
  description = "Please provide region."
  type        = string
}

variable "resource_naming_prefix" {
  description = "Please provide naming prefix for your resources"
  type        = string
}

variable "oke_vcn_cidr_blocks" {
  description = "VCN CIDR Block for OKE"
  default = "10.0.0.0/16"
}

variable "oke_k8sapiendpoint_subnet_cidr_block" {
  description = "Subnet CIDR Block for OKE API Endpoint"
  default = "10.0.0.0/24"
}

variable "oke_service_lb_subnet_cidr_block" {
  description = "Subnet CIDR Block for Service Load Balancer"
  default = "10.0.1.0/24"
}

variable "oke_nodepool_cidr_block" {
  description = "Subnet CIDR Block for worker nodepool"
  default = "10.0.2.0/24"
}

# variable "kubernetes_version" {
#   description = "Kubernetes version"
# }

# variable "ssh_public_key" {
#   description = "SSH public key to access node"
#   type        = string
# }

# variable "node_shape" {
#   description = "Instance shape of the node"
#   default = "VM.Standard.E4.Flex"
# }

# variable "shape_ocpus" {
#   description = "Number of OCPUs of each node"
#   default = "8"
# }

# variable "shape_mems" {
#   description = "Memory of each node in GB"
#   default = "128"
# }

# variable "node_size" {
#   description = "Number of worker nodes"
#   default = "2"
# }

# variable "image_os_id" {
#   description = "OS Image OCID of the node pool"
# }

data "oci_core_services" "all_services" {
}

data oci_identity_availability_domain AD-1 {
  compartment_id = var.compartment_ocid
  ad_number      = "1"
}
# data oci_identity_availability_domain AD-2 {
#   compartment_id = var.compartment_ocid
#   ad_number      = "2"
# }
# data oci_identity_availability_domain AD-3 {
#   compartment_id = var.compartment_ocid
#   ad_number      = "3"
# }

# data oci_objectstorage_namespace os_namespace {
#   compartment_id = var.compartment_ocid
# }