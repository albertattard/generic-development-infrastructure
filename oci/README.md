# Create compute instance with different Oracle Java and different Oracle GraalVM

Create compute instance with different Oracle Java and different Oracle GraalVM.

## Prerequisites

- Oracle OCI account

  Create an [OCI account](https://cloud.oracle.com/) and create/download an
  API key

- [Terraform](https://www.terraform.io/)

- The OCI Pre-Authenticated link from where the binaries can be downloaded. For
  more information about this, please contact Albert Attard
  (`albert.attard@oracle.com`).

## Set up

1. Create an SSH key pair, that will be used to authenticate/log-in the
   instance.

   This example assumes that the private key is found at
   `~/.ssh/ssh-key-oci-instance.key`.

2. Create the `./terraform/terraform.tfvars` file and provide a value to each
   variable. Following is a **sample**.

   ```terraform
   name_prefix                     = "Java Development Environment"
   dns_label                       = "jde"
   instance_vnic_display_name      = "dev"
   region                          = "us-ashburn-1"
   tenancy_id                      = "ocid1.tenancy.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
   compartment_id                  = "ocid1.compartment.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
   ssh_authorized_keys             = []
   ssh_private_key_file            = "~/.ssh/xxxxxx.key"
   image_source_id                 = "ocid1.image.oc1.iad.aaaaaaaap4fhruwd77p4kby5lhv5hacruznfu4clgueiixgciz747pld7sha"
   binaries_pre_authenticated_link = "https://xxxxxx.oci.customer-oci.com/p/xxxxxx/n/xxxxxx/b/generic-development-infrastructure/o/binaries"
   freeform_tags                   = {}
   defined_tags                    = {}
   ```

   Please note that some of these values are masked. Update these variables with
   proper values before proceeding.

   Each variable is described below

   - `name_prefix`: This setup creates several resources in OCI. These OCI
     resources will use this prefix in their name. For example, the OCI compute
     instance will have the following name:
     `${var.name_prefix} Public Instance`.
   - `dns_label`: This setup creates a VCN and used the value of this variable
     as the DNS name for this VCN. Please refer to the
     [`./terraform/main.tf` terraform file](./terraform/main.tf) for more
     information about how this variable is used.
   - `instance_vnic_display_name`: This setup creates an OCI compute instance
     and attaches a VNIC to it. The value of this variable is used as the VNIC's
     name. This name will also be show as part of the prompt when login into
     this compute instance.
   - `region`: The
     [OCI region](https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm)
     where the resources will be created.
   - `tenancy_id`: The tenancy where the resources will be created. This
     variable is used to obtain the availability domain information.
   - `compartment_id`: The compartment (within the tenancy) where the resources
     will be created. Please note that the compartment needs to exists and this
     is not created as part of the setup. Furthermore, all resources are created
     directly under this compartment.
   - `ssh_authorized_keys`: This setup creates an OCI compute instance which ssh
     public/private key pair as means of authentication instead of password.
     These SSH public keys will be added to the OCI compute instance and are the
     only means of logging into the instance.
   - `ssh_private_key_file`: This setup configures the OCI compute instance by
     installing several versions of Java amongst other things. The SSH private
     key is used to upload the
     [`./terraform/scripts/bootstrap.sh` script](./terraform/scripts/bootstrap.sh)
     and then execute it. This SSH private key needs to match one of the
     `ssh_authorized_keys`.
   - `image_source_id`: This setup creates an OCI compute instance. This OCI
     compute instance uses this Oracle Linux image as its base. You can find the
     latest versions of the Oracle Linux 9.x Images
     [here](https://docs.oracle.com/en-us/iaas/images/oracle-linux-9x/). Make
     sure to select an image that belong to the same region as set by the
     `region` variable.
   - `binaries_pre_authenticated_link`: This setup creates an OCI compute
     instance and installs different versions of Java amongst other binaries.
     These binaries are downloaded from an OCI bucket using Per-Authenticated
     link. For example, the current version of Oracle Java 22 is expected to be
     downloaded from
     `${var.binaries_pre_authenticated_link}/jdk-22.0.2_linux-x64_bin.tar.gz`
     using HTTP GET request. Note that the `binaries_pre_authenticated_link`
     should not end with a `/` as one is always added.
   - `freeform_tags`: The freeform tags to be assigned to each OCI resource that
     is created as part of this setup. While this is optional and can be left
     blank, it is recommended to add a tag to group all the resources together.
   - `defined_tags`: The defined tags to be assigned to each OCI resource that
     is created as part of this setup. While this is optional and can be left
     blank, it is recommended to add a tag to group all the resources together.

   Please refer to the
   [`./terraform/main.tf` terraform file](./terraform/main.tf) for more
   information about how this variable is used.

3. Deploy the infrastructure

   Run the [`deploy`](./deploy) script from within this directory.

   ```shell
   $ ./deploy
   ```

   This will take about 30 minutes as it needs to download all the binaries and
   then install them and will create several resources including an OCI instance
   with different versions of Java installed.

   Once ready, it will print the public IP address of this instance and a
   command that can be used to ssh into this machine.

   ```
   ...
   instance_public_ip = "###.###.###.###"
   ssh_command = "ssh -i ~/.ssh/ssh-key-oci-instance.key opc@###.###.###.###"
   ```

4. (_Optional_) Verify that it is working.

   ```shell
   $ ssh -i ~/.ssh/ssh-key-oci-instance.key \
     "opc@$(terraform -chdir='./terraform' output -json | jq --raw-output '.instance_public_ip.value')"
   ```

   There is an alias for each JDK version that helps you to switch to this JDK
   quickly. Switch to JDK17 using the `java17` alias and verify the Java
   version.

   ```shell
   > java17
   > java --version
   ...
   ```

## Tear down

When ready, destroy the infrastructure so that you don't incur unnecessarily
charges, by running the `destroy` script from within the `./oci` directory.

```shell
$ ./destroy
```

This will destroy all resources that were created by the same terraform script.
