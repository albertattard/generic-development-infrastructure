terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.0.0"
    }
  }
}

provider "oci" {
  region = var.region
}

data "oci_identity_availability_domains" "available" {
  compartment_id = var.tenancy_id
}

locals {
  availability_domain = lookup(data.oci_identity_availability_domains.available.availability_domains[0], "name")
}

resource "oci_core_vcn" "this" {
  display_name   = "${var.name_prefix} VCN"
  compartment_id = var.compartment_id
  cidr_blocks    = ["10.10.0.0/16"]
  dns_label      = var.dns_label

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags]
  }
}

resource "oci_core_internet_gateway" "this" {
  display_name   = "Internet Gateway"
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  enabled        = true

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags]
  }
}

resource "oci_core_default_route_table" "this" {
  display_name               = "Default Routing Table"
  manage_default_resource_id = oci_core_vcn.this.default_route_table_id

  route_rules {
    description       = "Allow communication between the VCN and the internet (without this traffic from within the VCN will not find its way to the internet)"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.this.id
  }

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags]
  }
}

resource "oci_core_default_security_list" "this" {
  display_name               = "Default Security List"
  manage_default_resource_id = oci_core_vcn.this.default_security_list_id

  egress_security_rules {
    description = "Allow all egress traffic (without this traffic from within the VCN will not be allowed to the internet)"
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    description = "Allow SSH from the anywhere (without this cannot SSH to the public instance)"
    protocol    = "6"
    source      = "0.0.0.0/0"

    tcp_options {
      min = 22
      max = 22
    }
  }

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags]
  }
}

resource "oci_core_subnet" "public" {
  display_name               = "Public Subnet"
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.this.id
  cidr_block                 = "10.10.1.0/24"
  prohibit_internet_ingress  = false
  prohibit_public_ip_on_vnic = false
  dns_label                  = "public"

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags]
  }
}

resource "oci_core_instance" "public" {
  display_name        = "${var.name_prefix} Public Instance"
  compartment_id      = var.compartment_id
  availability_domain = local.availability_domain

  shape = "VM.Standard.E4.Flex"
  shape_config {
    memory_in_gbs = "32"
    ocpus         = "4"
  }

  create_vnic_details {
    display_name              = var.instance_vnic_display_name
    subnet_id                 = oci_core_subnet.public.id
    assign_private_dns_record = true
    assign_public_ip          = true
    defined_tags              = var.defined_tags
    freeform_tags             = var.freeform_tags
  }

  metadata = {
    "ssh_authorized_keys" = join("\n", var.ssh_authorized_keys)
  }

  source_details {
    source_id               = var.image_source_id
    source_type             = "image"
    boot_volume_size_in_gbs = "1024"
  }

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags, create_vnic_details[0].defined_tags]
  }
}

resource "null_resource" "upload_files" {
  depends_on = [
    oci_core_instance.public,
  ]

  provisioner "file" {
    connection {
      agent       = false
      timeout     = "5m"
      host        = oci_core_instance.public.public_ip
      user        = "opc"
      private_key = file(var.ssh_private_key_file)
    }

    source      = "./binaries/jdk-8u421-linux-x64.tar.gz"
    destination = "/tmp/jdk-1.8.tar.gz"
  }

  provisioner "file" {
    connection {
      agent       = false
      timeout     = "5m"
      host        = oci_core_instance.public.public_ip
      user        = "opc"
      private_key = file(var.ssh_private_key_file)
    }

    source      = "./binaries/jdk-8u421-perf-linux-x64.tar.gz"
    destination = "/tmp/jdk-1.8-perf.tar.gz"
  }

  provisioner "file" {
    connection {
      agent       = false
      timeout     = "5m"
      host        = oci_core_instance.public.public_ip
      user        = "opc"
      private_key = file(var.ssh_private_key_file)
    }

    source      = "./binaries/jdk-9.0.4_linux-x64_bin.tar.gz"
    destination = "/tmp/jdk-9.tar.gz"
  }

  provisioner "file" {
    connection {
      agent       = false
      timeout     = "5m"
      host        = oci_core_instance.public.public_ip
      user        = "opc"
      private_key = file(var.ssh_private_key_file)
    }

    source      = "./binaries/jdk-10.0.2_linux-x64_bin.tar.gz"
    destination = "/tmp/jdk-10.tar.gz"
  }

  provisioner "file" {
    connection {
      agent       = false
      timeout     = "5m"
      host        = oci_core_instance.public.public_ip
      user        = "opc"
      private_key = file(var.ssh_private_key_file)
    }

    source      = "./binaries/jdk-11.0.24_linux-x64_bin.tar.gz"
    destination = "/tmp/jdk-11.tar.gz"
  }

  provisioner "file" {
    connection {
      agent       = false
      timeout     = "5m"
      host        = oci_core_instance.public.public_ip
      user        = "opc"
      private_key = file(var.ssh_private_key_file)
    }

    source      = "./binaries/jdk-12.0.2_linux-x64_bin.tar.gz"
    destination = "/tmp/jdk-12.tar.gz"
  }

  provisioner "file" {
    connection {
      agent       = false
      timeout     = "5m"
      host        = oci_core_instance.public.public_ip
      user        = "opc"
      private_key = file(var.ssh_private_key_file)
    }

    source      = "./binaries/jdk-13.0.2_linux-x64_bin.tar.gz"
    destination = "/tmp/jdk-13.tar.gz"
  }

  provisioner "file" {
    connection {
      agent       = false
      timeout     = "5m"
      host        = oci_core_instance.public.public_ip
      user        = "opc"
      private_key = file(var.ssh_private_key_file)
    }

    source      = "./binaries/jdk-14.0.2_linux-x64_bin.tar.gz"
    destination = "/tmp/jdk-14.tar.gz"
  }

  provisioner "file" {
    connection {
      agent       = false
      timeout     = "5m"
      host        = oci_core_instance.public.public_ip
      user        = "opc"
      private_key = file(var.ssh_private_key_file)
    }

    source      = "./binaries/jdk-15.0.2_linux-x64_bin.tar.gz"
    destination = "/tmp/jdk-15.tar.gz"
  }

  provisioner "file" {
    connection {
      agent       = false
      timeout     = "5m"
      host        = oci_core_instance.public.public_ip
      user        = "opc"
      private_key = file(var.ssh_private_key_file)
    }

    source      = "./binaries/jdk-16.0.2_linux-x64_bin.tar.gz"
    destination = "/tmp/jdk-16.tar.gz"
  }

  provisioner "file" {
    connection {
      agent       = false
      timeout     = "5m"
      host        = oci_core_instance.public.public_ip
      user        = "opc"
      private_key = file(var.ssh_private_key_file)
    }

    source      = "./binaries/jdk-17.0.12_linux-x64_bin.tar.gz"
    destination = "/tmp/jdk-17.tar.gz"
  }

  provisioner "file" {
    connection {
      agent       = false
      timeout     = "5m"
      host        = oci_core_instance.public.public_ip
      user        = "opc"
      private_key = file(var.ssh_private_key_file)
    }

    source      = "./binaries/jdk-18.0.2.1_linux-x64_bin.tar.gz"
    destination = "/tmp/jdk-18.tar.gz"
  }

  provisioner "file" {
    connection {
      agent       = false
      timeout     = "5m"
      host        = oci_core_instance.public.public_ip
      user        = "opc"
      private_key = file(var.ssh_private_key_file)
    }

    source      = "./binaries/jdk-19.0.2_linux-x64_bin.tar.gz"
    destination = "/tmp/jdk-19.tar.gz"
  }

  provisioner "file" {
    connection {
      agent       = false
      timeout     = "5m"
      host        = oci_core_instance.public.public_ip
      user        = "opc"
      private_key = file(var.ssh_private_key_file)
    }

    source      = "./binaries/jdk-20.0.2_linux-x64_bin.tar.gz"
    destination = "/tmp/jdk-20.tar.gz"
  }

  provisioner "file" {
    connection {
      agent       = false
      timeout     = "5m"
      host        = oci_core_instance.public.public_ip
      user        = "opc"
      private_key = file(var.ssh_private_key_file)
    }

    source      = "./binaries/jdk-21.0.4_linux-x64_bin.tar.gz"
    destination = "/tmp/jdk-21.tar.gz"
  }

  provisioner "file" {
    connection {
      agent       = false
      timeout     = "5m"
      host        = oci_core_instance.public.public_ip
      user        = "opc"
      private_key = file(var.ssh_private_key_file)
    }

    source      = "./binaries/jdk-22.0.2_linux-x64_bin.tar.gz"
    destination = "/tmp/jdk-22.tar.gz"
  }

  provisioner "file" {
    connection {
      agent       = false
      timeout     = "5m"
      host        = oci_core_instance.public.public_ip
      user        = "opc"
      private_key = file(var.ssh_private_key_file)
    }

    source      = "./binaries/openjdk-23-ea+31_linux-x64_bin.tar.gz"
    destination = "/tmp/jdk-23.tar.gz"
  }

  provisioner "file" {
    connection {
      agent       = false
      timeout     = "5m"
      host        = oci_core_instance.public.public_ip
      user        = "opc"
      private_key = file(var.ssh_private_key_file)
    }

    source      = "./binaries/graalvm-jdk-17.0.12_linux-x64_bin.tar.gz"
    destination = "/tmp/graalvm-17.tar.gz"
  }

  provisioner "file" {
    connection {
      agent       = false
      timeout     = "5m"
      host        = oci_core_instance.public.public_ip
      user        = "opc"
      private_key = file(var.ssh_private_key_file)
    }

    source      = "./binaries/graalvm-jdk-21.0.4_linux-x64_bin.tar.gz"
    destination = "/tmp/graalvm-21.tar.gz"
  }

  provisioner "file" {
    connection {
      agent       = false
      timeout     = "5m"
      host        = oci_core_instance.public.public_ip
      user        = "opc"
      private_key = file(var.ssh_private_key_file)
    }

    source      = "./binaries/graalvm-jdk-22.0.2_linux-x64_bin.tar.gz"
    destination = "/tmp/graalvm-22.tar.gz"
  }

  provisioner "file" {
    connection {
      agent       = false
      timeout     = "5m"
      host        = oci_core_instance.public.public_ip
      user        = "opc"
      private_key = file(var.ssh_private_key_file)
    }

    source      = "./binaries/x86_64-linux-musl-native.tgz"
    destination = "/tmp/x86_64-linux-musl-native.tgz"
  }

  provisioner "file" {
    connection {
      agent       = false
      timeout     = "5m"
      host        = oci_core_instance.public.public_ip
      user        = "opc"
      private_key = file(var.ssh_private_key_file)
    }

    source      = "./binaries/zlib-1.3.1.tar.gz"
    destination = "/tmp/zlib-1.3.1.tar.gz"
  }

  provisioner "file" {
    connection {
      agent       = false
      timeout     = "5m"
      host        = oci_core_instance.public.public_ip
      user        = "opc"
      private_key = file(var.ssh_private_key_file)
    }

    source      = "./binaries/kotlin-compiler-2.0.0.zip"
    destination = "/tmp/kotlin-compiler.zip"
  }

  provisioner "file" {
    connection {
      agent       = false
      timeout     = "5m"
      host        = oci_core_instance.public.public_ip
      user        = "opc"
      private_key = file(var.ssh_private_key_file)
    }

    source      = "./binaries/toolchains.xml"
    destination = "/tmp/toolchains.xml"
  }

  provisioner "file" {
    connection {
      agent       = false
      timeout     = "5m"
      host        = oci_core_instance.public.public_ip
      user        = "opc"
      private_key = file(var.ssh_private_key_file)
    }

    source      = "./binaries/checksums.txt"
    destination = "/tmp/checksums.txt"
  }
}

resource "null_resource" "bootstrap" {
  depends_on = [
    null_resource.upload_files,
  ]

  provisioner "file" {
    connection {
      agent       = false
      timeout     = "5m"
      host        = oci_core_instance.public.public_ip
      user        = "opc"
      private_key = file(var.ssh_private_key_file)
    }

    source      = "./scripts/bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    connection {
      agent       = false
      timeout     = "5m"
      host        = oci_core_instance.public.public_ip
      user        = "opc"
      private_key = file(var.ssh_private_key_file)
    }

    inline = [
      "sudo bash /tmp/bootstrap.sh"
    ]
  }
}

output "instance_public_ip" {
  description = "The public IP address of the public instance"
  value       = oci_core_instance.public.public_ip
}

output "ssh_command" {
  description = "The SSH command than can be used to access the public instance"
  value       = "ssh -i ${var.ssh_private_key_file} opc@${oci_core_instance.public.public_ip}"
}
