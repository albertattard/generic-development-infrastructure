# Create compute instance with different Oracle Java and different Oracle GraalVM

Create compute instance with different Oracle Java and different Oracle GraalVM.

## Prerequisites

- Oracle OCI account

  Create an [OCI account](https://cloud.oracle.com/) and create/download an
  API key

- [Terraform](https://www.terraform.io/)

## Set up

1. Create an SSH key pair, that will be used to authenticate/log-in the
   instance.

   This example assumes that the private key is found at
   `~/.ssh/ssh-key-oci-instance.key`.

2. Create the `./terraform/terraform.tfvars` file and provide a value to each
   variable. Following is a sample.

   ```terraform
   name_prefix                = "Java Development Environment"
   dns_label                  = "jde"
   instance_vnic_display_name = "dev"
   region         = "us-ashburn-1"
   tenancy_id     = "ocid1.tenancy.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
   compartment_id = "ocid1.compartment.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
   freeform_tags = {
   }
   defined_tags = {
   }
   ssh_authorized_keys = [
   ]
   ssh_private_key_file = "~/.ssh/ssh-key-oci-instance.key"
   image_source_id      = "ocid1.image.oc1.iad.aaaaaaaakp5agw5rxfiq6nede7ousfcdfuflfjgsu7bstmnx737ah4ylmu6q"
   ```

3. Download the following Linux x86 (`taz.gz`) binaries and save them in the
   [`./oci/terraform/binaries`](./oci/terraform/binaries) directory.

   - [Latest Oracle Java 8](https://www.oracle.com/java/technologies/downloads/#java8-linux)
   - [Latest Oracle Java 8 Enterprise Performance Pack](https://www.oracle.com/java/technologies/downloads/#jepp-linux)
   - [Oracle Java 9.0.4](https://www.oracle.com/java/technologies/javase/javase9-archive-downloads.html)
     Please note that this is an unsupported version of Java and it is only used
     for testing purposes only. Do not run your application with this old and
     unmaintained version of Java.
   - [Oracle Java 10.0.2](https://www.oracle.com/java/technologies/java-archive-javase10-downloads.html)
     Please note that this is an unsupported version of Java and it is only used
     for testing purposes only. Do not run your application with this old and
     unmaintained version of Java.
   - [Latest Oracle Java 11](https://www.oracle.com/java/technologies/downloads/#java11-linux)
   - [Oracle Java 12.0.2](https://www.oracle.com/java/technologies/javase/jdk12-archive-downloads.html)
     Please note that this is an unsupported version of Java and it is only used
     for testing purposes only. Do not run your application with this old and
     unmaintained version of Java.
   - [Oracle Java 13.0.2](https://www.oracle.com/java/technologies/javase/jdk13-archive-downloads.html)
     Please note that this is an unsupported version of Java and it is only used
     for testing purposes only. Do not run your application with this old and
     unmaintained version of Java.
   - [Oracle Java 14.0.2](https://www.oracle.com/java/technologies/javase/jdk14-archive-downloads.html)
     Please note that this is an unsupported version of Java and it is only used
     for testing purposes only. Do not run your application with this old and
     unmaintained version of Java.
   - [Oracle Java 15.0.2](https://www.oracle.com/java/technologies/javase/jdk15-archive-downloads.html)
     Please note that this is an unsupported version of Java and it is only used
     for testing purposes only. Do not run your application with this old and
     unmaintained version of Java.
   - [Oracle Java 16.0.2](https://www.oracle.com/java/technologies/javase/jdk16-archive-downloads.html)
     Please note that this is an unsupported version of Java and it is only used
     for testing purposes only. Do not run your application with this old and
     unmaintained version of Java.
   - [Latest Oracle Java 17](https://www.oracle.com/java/technologies/downloads/#jdk17-linux)
   - [Oracle Java 18.0.2.1](https://www.oracle.com/java/technologies/javase/jdk18-archive-downloads.html)
     Please note that this is an unsupported version of Java and it is only used
     for testing purposes only. Do not run your application with this old and
     unmaintained version of Java.
   - [Oracle Java 19.0.2](https://www.oracle.com/java/technologies/javase/jdk19-archive-downloads.html)
     Please note that this is an unsupported version of Java and it is only used
     for testing purposes only. Do not run your application with this old and
     unmaintained version of Java.
   - [Oracle Java 20.0.2](https://www.oracle.com/java/technologies/javase/jdk20-archive-downloads.html)
   - [Latest Oracle Java 21](https://www.oracle.com/java/technologies/downloads/#jdk21-linux)
   - [Latest Oracle Java 22](https://www.oracle.com/java/technologies/downloads/#jdk22-linux)
   - [Early Access Oracle Java 23](https://jdk.java.net/23/)
   - [Latest Oracle GraalVM for Java 17](https://www.oracle.com/java/technologies/downloads/#graalvmjava17-linux)
   - [Latest Oracle GraalVM for Java 21](https://www.oracle.com/java/technologies/downloads/#graalvmjava21-linux)
   - [Latest Oracle GraalVM for Java 22](https://www.oracle.com/java/technologies/downloads/#graalvmjava22-linux)
   - [Latest kotlin compiler](https://github.com/JetBrains/kotlin/releases/)
   - [musl libc (v10 as there seems to be incompetabilities with the latest version)](http://more.musl.cc/10/x86_64-linux-musl/x86_64-linux-musl-native.tgz)
   - [zlib compression library (v 1.3.1)](https://zlib.net/zlib-1.3.1.tar.gz)

   **Please do not include these binaries in the repository**.

   Don't forget to update the
   [`./terraform/binaries/checksums.txt`](./terraform/binaries/checksums.txt)
   file with the correct sha256 checksum.

4. Deploy the infrastructure

   Run the [`deploy`](./deploy) script from within this directory.

   ```shell
   $ ./deploy
   ```

   This will take about 10 minutes as it needs to upload all the JDKs and then
   install them and will create several resources including an OCI instance with
   different versions of Java installed.

   Once ready, it will print the public IP address of this instance and a
   command that can be used to ssh into this machine.

   ```
   ...
   instance_public_ip = "###.###.###.###"
   ssh_command = "ssh -i ~/.ssh/ssh-key-oci-instance.key opc@###.###.###.###"
   ```

5. Verify that it is working.

   ```shell
   $ ssh -i ~/.ssh/ssh-key-oci-instance.key opc@###.###.###.###
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
