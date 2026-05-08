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
  default     = "us-ashburn-1"
}

variable "tenancy_id" {
  type        = string
  description = "The Tenancy OCID where the resources will be created"
}

variable "compartment_id" {
  type        = string
  description = "The compartment OCID where the resources will be placed"
}

variable "ssh_authorized_keys" {
  type        = list(string)
  description = "The list of public keys to be added to all compute instances"
}

variable "ssh_ingress_cidr_blocks" {
  type        = list(string)
  description = "The CIDR blocks that are allowed to SSH to the public compute instance"

  validation {
    condition = length(var.ssh_ingress_cidr_blocks) > 0 && alltrue([
      for cidr_block in var.ssh_ingress_cidr_blocks :
      can(cidrhost(cidr_block, 0)) &&
      cidr_block == format("%s/%s", cidrhost(cidr_block, 0), split("/", cidr_block)[1])
    ])
    error_message = "Provide at least one valid canonical CIDR block. For one laptop public IPv4 address, use /32, for example 203.0.113.10/32. Broader ranges must use the network address, for example 203.0.113.0/24."
  }
}

variable "ssh_private_key_file" {
  type        = string
  description = <<EOF
The path to the local private key matching one of the public keys. This is used
to configure the public compute instances from this computer as part of the
terraform script set up.
EOF
}

variable "image_source_id" {
  type        = string
  description = <<EOF
The OCI image ID for the compute instances
(See: https://docs.oracle.com/en-us/iaas/images/oracle-linux-10x/index.htm)
EOF
  default     = "ocid1.image.oc1.iad.aaaaaaaalkf4mkx2efw7xghafasr2ehia42ombnybkbmejjtvfa6nd3yttfa"
}

variable "instance_shape" {
  type        = string
  description = <<EOF
The compute shape
(See: https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm)
EOF
  default     = "VM.Standard.E5.Flex"
}

variable "instance_shape_memory_in_gbs" {
  type        = number
  description = <<EOF
The memory available to the compute instance
(See: https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm)
EOF
  default     = 32
}

variable "instance_shape_ocpus" {
  type        = number
  description = <<EOF
The number of CPUs that the compute will have
(See: https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm)
EOF
  default     = 4
}

variable "binaries_pre_authenticated_link" {
  type        = string
  description = <<EOF
The OCI Pre-Authenticated link used to download the binaries from the OCI
bucket. Please talk to Albert Attard (albert.attard@oracle.com) for more
information about this.
EOF
}

variable "freeform_tags" {
  type        = map(string)
  description = "The freeform tags that will be applied to all resources"
}

variable "defined_tags" {
  type        = map(string)
  description = "The defined tags that will be applied to all resources"
}
