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

data "oci_core_services" "all_services" {
}

data oci_identity_availability_domain AD-1 {
  compartment_id = var.compartment_ocid
  ad_number      = "1"
}