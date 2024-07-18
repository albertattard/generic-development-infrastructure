variable "name_prefix" {
  type        = string
  description = "A prefix that will be used when naming resources"
}

variable "dns_label" {
  type        = string
  description = "The DNS label to be used for the network"
}

variable "instance_vnic_display_name" {
  type        = string
  description = "The name to be given to the public instance VNIC"
}

variable "region" {
  type        = string
  description = "The OCI region where the resources will be created"
}

variable "tenancy_id" {
  type        = string
  description = "The Tenancy OCID where the resources will be created"
}

variable "compartment_id" {
  type        = string
  description = "The compartment OCID where the resources will be placed"
}

variable "freeform_tags" {
  type        = map(string)
  description = "The freeform tags that will be applied to all resources"
}

variable "defined_tags" {
  type        = map(string)
  description = "The defined tags that will be applied to all resources"
}

variable "ssh_authorized_keys" {
  type        = list(string)
  description = "The list of public keys to be added to all compute instances"
}

variable "ssh_private_key_file" {
  type        = string
  description = <<EOF
The path to the local private key matching one of the public keys. This is used
to configre the public compute instances from this computer as part of the
terraform script set up.
EOF
}

variable "image_source_id" {
  type        = string
  description = "The OCI image ID for the compute instances"
}
