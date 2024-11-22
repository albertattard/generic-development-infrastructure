#!/bin/bash


set -e

# ------------------------------------------------------------------------------
# This script downloads binaries using the provided Pre-Authenticated link.
# Kindly note that while some of these binaries are freely available others are
# not. Do not make the Per-Authenticated link publicly available.
#
# For more information or require additional help, please speak to Albert Attard
# (albert.attard@oracle.com).
# ------------------------------------------------------------------------------
BINARIES_PRE_AUTHENTICATED_LINK="$1"
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Verify that the this script can download the files using the provided
# BINARIES_PRE_AUTHENTICATED_LINK
# ------------------------------------------------------------------------------
BINARIES_PRE_AUTHENTICATED_LINK_RESPONSE=$(curl --silent --location "${BINARIES_PRE_AUTHENTICATED_LINK}/ok")
if [ "$BINARIES_PRE_AUTHENTICATED_LINK_RESPONSE" != "ok" ]; then
  echo "Cannot access the binaries using the provided binaries pre authenticated link"
  exit 1
fi
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Upgrade the system to the current release (takes several minutes to run)
# Note that the updates will vary depending on when this command executes
# ------------------------------------------------------------------------------
# dnf upgrade -y
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Fill the remain space. Otherwise we will have unallocated space!!
# Based on: https://learnoci.cloud/how-to-extend-a-boot-volume-in-oci-linux-instance-13effa0297b3
# ------------------------------------------------------------------------------
echo 'Filling the remaining space'
/usr/libexec/oci-growfs --yes
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Allow unprivileged processes to bind to port 80. This is not really necessary
# and kept the code here just in case we need it.
# ------------------------------------------------------------------------------
# sysctl -w net.ipv4.ip_unprivileged_port_start=80
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Oracle releases four critical patch updates per year, and these versions of
# Java need to be updated every three months. Their values are grouped here for
# convenience, so that you don't have to go to multiple places to update a
# version
# ------------------------------------------------------------------------------
# https://www.oracle.com/java/technologies/downloads/#java8
# https://www.oracle.com/a/tech/docs/8u431checksum.html
JAVA_1_8_BINARY_FILE='jdk-8u431-linux-x64.tar.gz'
JAVA_1_8_BINARY_SHA256='b396978a716b7d23ccccabfe5c47c3b75d2434d7f8f7af690bc648172382720d'

# https://www.oracle.com/java/technologies/downloads/#jepp
# https://www.oracle.com/a/tech/docs/8u431checksum.html
JAVA_1_8_PERF_BINARY_FILE='jdk-8u431-perf-linux-x64.tar.gz'
JAVA_1_8_PERF_BINARY_SHA256='a610bfcb300beee600ecfc46dc74a6d3a8a00e7bde0fe1be32598c6040b9849a'

# https://www.oracle.com/java/technologies/downloads/#java11
# https://www.oracle.com/a/tech/docs/11-0-25-checksum.html
JAVA_11_BINARY_FILE='jdk-11.0.25_linux-x64_bin.tar.gz'
JAVA_11_BINARY_SHA256='d22d0fcca761861a1eb2f5f6eb116c933354e8b1f76b3cda189c722cc0177c98'

# https://www.oracle.com/java/technologies/downloads/#java17
# https://www.oracle.com/a/tech/docs/17-0-13-checksum.html
JAVA_17_BINARY_FILE="jdk-17.0.13_linux-x64_bin.tar.gz"
JAVA_17_BINARY_SHA256='f7a6fdebeb11840e1f5314bc330feb75b67e52491cf39073dbf3e51e3889ff08'

# https://www.oracle.com/java/technologies/downloads/#java21
JAVA_21_BINARY_FILE='jdk-21.0.5_linux-x64_bin.tar.gz'
JAVA_21_BINARY_SHA256='9c2f7c39e0d5b296ce50e563740694b2ebfe4a620415d1b2b848ba47bebceb47'

# https://www.oracle.com/java/technologies/downloads/#java23
JAVA_23_BINARY_FILE='jdk-23.0.1_linux-x64_bin.tar.gz'
JAVA_23_BINARY_SHA256='2bda38cd0f31d593b56ee5a607401bc6f245aafe07535b6525572861c2d15d6f'

# https://jdk.java.net/24/
JAVA_24_BINARY_FILE='openjdk-24-ea+19_linux-x64_bin.tar.gz'
JAVA_24_BINARY_SHA256='b283aeaeda2e1fb83a01a61a370e2e95e217a00aa3a51641d1b65244b60b05f6'

# https://www.oracle.com/java/technologies/downloads/#graalvmjava17
# https://www.oracle.com/a/tech/docs/graalvm17-0-13-checksum.html
GRAALVM_17_BINARY_FILE='graalvm-jdk-17.0.13_linux-x64_bin.tar.gz'
GRAALVM_17_BINARY_SHA256='879a0678fdc8ff6d6a76f4af0681fb19ae0a75a767c3b384a61060e72b303d9e'

# https://www.oracle.com/java/technologies/downloads/#graalvmjava21
GRAALVM_21_BINARY_FILE='graalvm-jdk-21.0.5_linux-x64_bin.tar.gz'
GRAALVM_21_BINARY_SHA256='c1960d4f9d278458bde1cd15115ac2f0b3240cb427d51cfeceb79dab91a7f5c9'

# https://www.oracle.com/java/technologies/downloads/#graalvmjava23
GRAALVM_23_BINARY_FILE='graalvm-jdk-23.0.1_linux-x64_bin.tar.gz'
GRAALVM_23_BINARY_SHA256='46ec9582ebe114f93470403f2cc123238ac0c7982129c358af7d8e1de52dd663'
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Download the binaries using the provided Pre-Authenticated link. Kindly note
# that while some of these binaries are freely available others are not. Do not
# make the Per-Authenticated link publicly available.
#
# For more information or require additional help, please speak to Albert Attard
# (albert.attard@oracle.com).
# ------------------------------------------------------------------------------
echo 'Downloading the binaries'
curl --silent --location --output '/tmp/jdk-1.8.tar.gz'               "${BINARIES_PRE_AUTHENTICATED_LINK}/${JAVA_1_8_BINARY_FILE}"
curl --silent --location --output '/tmp/jdk-1.8-perf.tar.gz'          "${BINARIES_PRE_AUTHENTICATED_LINK}/${JAVA_1_8_PERF_BINARY_FILE}"
curl --silent --location --output '/tmp/jdk-9.tar.gz'                 "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-9.0.4_linux-x64_bin.tar.gz"
curl --silent --location --output '/tmp/jdk-10.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-10.0.2_linux-x64_bin.tar.gz"
curl --silent --location --output '/tmp/jdk-11.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/${JAVA_11_BINARY_FILE}"
curl --silent --location --output '/tmp/jdk-12.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-12.0.2_linux-x64_bin.tar.gz"
curl --silent --location --output '/tmp/jdk-13.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-13.0.2_linux-x64_bin.tar.gz"
curl --silent --location --output '/tmp/jdk-14.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-14.0.2_linux-x64_bin.tar.gz"
curl --silent --location --output '/tmp/jdk-15.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-15.0.2_linux-x64_bin.tar.gz"
curl --silent --location --output '/tmp/jdk-16.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-16.0.2_linux-x64_bin.tar.gz"
curl --silent --location --output '/tmp/jdk-17.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/${JAVA_17_BINARY_FILE}"
curl --silent --location --output '/tmp/jdk-18.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-18.0.2.1_linux-x64_bin.tar.gz"
curl --silent --location --output '/tmp/jdk-19.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-19.0.2_linux-x64_bin.tar.gz"
curl --silent --location --output '/tmp/jdk-20.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-20.0.2_linux-x64_bin.tar.gz"
curl --silent --location --output '/tmp/jdk-21.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/${JAVA_21_BINARY_FILE}"
curl --silent --location --output '/tmp/jdk-22.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-22.0.2_linux-x64_bin.tar.gz"
curl --silent --location --output '/tmp/jdk-22-jextract.tar.gz'       "${BINARIES_PRE_AUTHENTICATED_LINK}/openjdk-22-jextract+5-33_linux-x64_bin.tar.gz"
curl --silent --location --output '/tmp/jdk-23.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/${JAVA_23_BINARY_FILE}"
curl --silent --location --output '/tmp/jdk-23-valhalla.tar.gz'       "${BINARIES_PRE_AUTHENTICATED_LINK}/openjdk-23-valhalla+1-90_linux-x64_bin.tar.gz"
curl --silent --location --output '/tmp/jdk-24.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/${JAVA_24_BINARY_FILE}"
curl --silent --location --output '/tmp/jdk-24-leyden.tar.gz'         "${BINARIES_PRE_AUTHENTICATED_LINK}/openjdk-24-leyden+2-8_linux-x64_bin.tar.gz"
curl --silent --location --output '/tmp/jdk-24-loom.tar.gz'           "${BINARIES_PRE_AUTHENTICATED_LINK}/openjdk-24-loom+8-78_linux-x64_bin.tar.gz"
curl --silent --location --output '/tmp/graalvm-17.tar.gz'            "${BINARIES_PRE_AUTHENTICATED_LINK}/${GRAALVM_17_BINARY_FILE}"
curl --silent --location --output '/tmp/graalvm-21.tar.gz'            "${BINARIES_PRE_AUTHENTICATED_LINK}/${GRAALVM_21_BINARY_FILE}"
curl --silent --location --output '/tmp/graalvm-23.tar.gz'            "${BINARIES_PRE_AUTHENTICATED_LINK}/${GRAALVM_23_BINARY_FILE}"
curl --silent --location --output '/tmp/kotlin-compiler.zip'          "${BINARIES_PRE_AUTHENTICATED_LINK}/kotlin-compiler-2.0.0.zip"
curl --silent --location --output '/tmp/zlib-1.3.1.tar.gz'            "${BINARIES_PRE_AUTHENTICATED_LINK}/zlib-1.3.1.tar.gz"
curl --silent --location --output '/tmp/x86_64-linux-musl-native.tgz' "${BINARIES_PRE_AUTHENTICATED_LINK}/x86_64-linux-musl-native.tgz"
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Verify all the downloaded binaries
# ------------------------------------------------------------------------------
echo 'Verifying the downloaded binaries'
echo "${JAVA_1_8_BINARY_SHA256} /tmp/jdk-1.8.tar.gz"                                                      | sha256sum --check
echo "${JAVA_1_8_PERF_BINARY_SHA256} /tmp/jdk-1.8-perf.tar.gz"                                            | sha256sum --check
echo '90c4ea877e816e3440862cfa36341bc87d05373d53389ec0f2d54d4e8c95daa2 /tmp/jdk-9.tar.gz'                 | sha256sum --check
echo '6633c20d53c50c20835364d0f3e172e0cbbce78fff81867488f22a6298fa372b /tmp/jdk-10.tar.gz'                | sha256sum --check
echo "${JAVA_11_BINARY_SHA256} /tmp/jdk-11.tar.gz"                                                        | sha256sum --check
echo '2dde6fda89a4ec6e6560ed464e917861c9e40bf576e7a64856dafc55abaaff51 /tmp/jdk-12.tar.gz'                | sha256sum --check
echo 'e2214a723d611b4a781641061a24ca6024f2c57dbd9f75ca9d857cad87d9475f /tmp/jdk-13.tar.gz'                | sha256sum --check
echo 'cb811a86926cc0f529d16bec7bd2e25fb73e75125bbd1775cdb9a96998593dde /tmp/jdk-14.tar.gz'                | sha256sum --check
echo '54b29a3756671fcb4b6116931e03e86645632ec39361bc16ad1aaa67332c7c61 /tmp/jdk-15.tar.gz'                | sha256sum --check
echo '630e3e56c58f45db3788343ce842756d5a5a401a63884242cc6a141071285a62 /tmp/jdk-16.tar.gz'                | sha256sum --check
echo "${JAVA_17_BINARY_SHA256} /tmp/jdk-17.tar.gz"                                                        | sha256sum --check
echo 'cd905013facbb5c2b5354165cc372e327259de4991c28f31c7d4231dbf638934 /tmp/jdk-18.tar.gz'                | sha256sum --check
echo '59f26ace2727d0e9b24fc09d5a48393c9dbaffe04c932a02938e8d6d582058c6 /tmp/jdk-19.tar.gz'                | sha256sum --check
echo '499b59be8e3613c223e76f101598d7c28dc04b8e154d860edf2ed05980c67526 /tmp/jdk-20.tar.gz'                | sha256sum --check
echo "${JAVA_21_BINARY_SHA256} /tmp/jdk-21.tar.gz"                                                        | sha256sum --check
echo 'cbc13aaa2618659f44cb261f820f179832d611f0df35dd30a78d7dea6d717858 /tmp/jdk-22.tar.gz'                | sha256sum --check
echo '53d66299cda8d079aeff42b2cc765314e44b384f3e0ec2a7eb994bae62b4b728 /tmp/jdk-22-jextract.tar.gz'       | sha256sum --check
echo "${JAVA_23_BINARY_SHA256} /tmp/jdk-23.tar.gz"                                                        | sha256sum --check
echo '5235afaf5ecc86f2237458cf40f8ed965939372f606edbd0fc46e1ee2e69f5f5 /tmp/jdk-23-valhalla.tar.gz'       | sha256sum --check
echo "${JAVA_24_BINARY_SHA256} /tmp/jdk-24.tar.gz"                                                        | sha256sum --check
echo '7a6f9f5a602377b882e647ae9312706c6873afc582d2612681e6fbe9e122a088 /tmp/jdk-24-leyden.tar.gz'         | sha256sum --check
echo '523c3483ad9f3ab154403d60804746dd74572511ff1b64f3c8c1be687e1eaa4d /tmp/jdk-24-loom.tar.gz'           | sha256sum --check
echo "${GRAALVM_17_BINARY_SHA256} /tmp/graalvm-17.tar.gz"                                                 | sha256sum --check
echo "${GRAALVM_21_BINARY_SHA256} /tmp/graalvm-21.tar.gz"                                                 | sha256sum --check
echo "${GRAALVM_23_BINARY_SHA256} /tmp/graalvm-23.tar.gz"                                                 | sha256sum --check
echo 'ef578730976154fd2c5968d75af8c2703b3de84a78dffe913f670326e149da3b /tmp/kotlin-compiler.zip'          | sha256sum --check
echo '9a93b2b7dfdac77ceba5a558a580e74667dd6fede4585b91eefb60f03b72df23 /tmp/zlib-1.3.1.tar.gz'            | sha256sum --check
echo 'd587e1fadefaad60687dd1dcb9b278e7b587e12cb1dc48cae42a9f52bb8613a7 /tmp/x86_64-linux-musl-native.tgz' | sha256sum --check
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install (extract) Oracle Java and Oracle GraalVM
# ------------------------------------------------------------------------------
echo 'Installing (extracting) Oracle Java and Oracle GraalVM'
rm -rf '/usr/lib/jvm'

mkdir -p '/usr/lib/jvm/jdk-1.8'
mkdir -p '/usr/lib/jvm/jdk-1.8-perf'
mkdir -p '/usr/lib/jvm/jdk-9'
mkdir -p '/usr/lib/jvm/jdk-10'
mkdir -p '/usr/lib/jvm/jdk-11'
mkdir -p '/usr/lib/jvm/jdk-12'
mkdir -p '/usr/lib/jvm/jdk-13'
mkdir -p '/usr/lib/jvm/jdk-14'
mkdir -p '/usr/lib/jvm/jdk-15'
mkdir -p '/usr/lib/jvm/jdk-16'
mkdir -p '/usr/lib/jvm/jdk-17'
mkdir -p '/usr/lib/jvm/jdk-18'
mkdir -p '/usr/lib/jvm/jdk-19'
mkdir -p '/usr/lib/jvm/jdk-20'
mkdir -p '/usr/lib/jvm/jdk-21'
mkdir -p '/usr/lib/jvm/jdk-22'
mkdir -p '/usr/lib/jvm/jdk-22-jextract'
mkdir -p '/usr/lib/jvm/jdk-23'
mkdir -p '/usr/lib/jvm/jdk-23-valhalla'
mkdir -p '/usr/lib/jvm/jdk-24'
mkdir -p '/usr/lib/jvm/jdk-24-leyden'
mkdir -p '/usr/lib/jvm/jdk-24-loom'
mkdir -p '/usr/lib/jvm/graalvm-17'
mkdir -p '/usr/lib/jvm/graalvm-21'
mkdir -p '/usr/lib/jvm/graalvm-23'

tar --extract --file '/tmp/jdk-1.8.tar.gz'         --directory '/usr/lib/jvm/jdk-1.8'         --strip-components 1
tar --extract --file '/tmp/jdk-1.8-perf.tar.gz'    --directory '/usr/lib/jvm/jdk-1.8-perf'    --strip-components 1
tar --extract --file '/tmp/jdk-9.tar.gz'           --directory '/usr/lib/jvm/jdk-9'           --strip-components 1
tar --extract --file '/tmp/jdk-10.tar.gz'          --directory '/usr/lib/jvm/jdk-10'          --strip-components 1
tar --extract --file '/tmp/jdk-11.tar.gz'          --directory '/usr/lib/jvm/jdk-11'          --strip-components 1
tar --extract --file '/tmp/jdk-12.tar.gz'          --directory '/usr/lib/jvm/jdk-12'          --strip-components 1
tar --extract --file '/tmp/jdk-13.tar.gz'          --directory '/usr/lib/jvm/jdk-13'          --strip-components 1
tar --extract --file '/tmp/jdk-14.tar.gz'          --directory '/usr/lib/jvm/jdk-14'          --strip-components 1
tar --extract --file '/tmp/jdk-15.tar.gz'          --directory '/usr/lib/jvm/jdk-15'          --strip-components 1
tar --extract --file '/tmp/jdk-16.tar.gz'          --directory '/usr/lib/jvm/jdk-16'          --strip-components 1
tar --extract --file '/tmp/jdk-17.tar.gz'          --directory '/usr/lib/jvm/jdk-17'          --strip-components 1
tar --extract --file '/tmp/jdk-18.tar.gz'          --directory '/usr/lib/jvm/jdk-18'          --strip-components 1
tar --extract --file '/tmp/jdk-19.tar.gz'          --directory '/usr/lib/jvm/jdk-19'          --strip-components 1
tar --extract --file '/tmp/jdk-20.tar.gz'          --directory '/usr/lib/jvm/jdk-20'          --strip-components 1
tar --extract --file '/tmp/jdk-21.tar.gz'          --directory '/usr/lib/jvm/jdk-21'          --strip-components 1
tar --extract --file '/tmp/jdk-22.tar.gz'          --directory '/usr/lib/jvm/jdk-22'          --strip-components 1
tar --extract --file '/tmp/jdk-22-jextract.tar.gz' --directory '/usr/lib/jvm/jdk-22-jextract' --strip-components 1
tar --extract --file '/tmp/jdk-23.tar.gz'          --directory '/usr/lib/jvm/jdk-23'          --strip-components 1
tar --extract --file '/tmp/jdk-23-valhalla.tar.gz' --directory '/usr/lib/jvm/jdk-23-valhalla' --strip-components 1
tar --extract --file '/tmp/jdk-24.tar.gz'          --directory '/usr/lib/jvm/jdk-24'          --strip-components 1
tar --extract --file '/tmp/jdk-24-leyden.tar.gz'   --directory '/usr/lib/jvm/jdk-24-leyden'   --strip-components 1
tar --extract --file '/tmp/jdk-24-loom.tar.gz'     --directory '/usr/lib/jvm/jdk-24-loom'     --strip-components 1
tar --extract --file '/tmp/graalvm-17.tar.gz'      --directory '/usr/lib/jvm/graalvm-17'      --strip-components 1
tar --extract --file '/tmp/graalvm-21.tar.gz'      --directory '/usr/lib/jvm/graalvm-21'      --strip-components 1
tar --extract --file '/tmp/graalvm-23.tar.gz'      --directory '/usr/lib/jvm/graalvm-23'      --strip-components 1

rm -f '/tmp/jdk-1.8.tar.gz'
rm -f '/tmp/jdk-1.8-perf.tar.gz'
rm -f '/tmp/jdk-9.tar.gz'
rm -f '/tmp/jdk-10.tar.gz'
rm -f '/tmp/jdk-11.tar.gz'
rm -f '/tmp/jdk-12.tar.gz'
rm -f '/tmp/jdk-13.tar.gz'
rm -f '/tmp/jdk-14.tar.gz'
rm -f '/tmp/jdk-15.tar.gz'
rm -f '/tmp/jdk-16.tar.gz'
rm -f '/tmp/jdk-17.tar.gz'
rm -f '/tmp/jdk-18.tar.gz'
rm -f '/tmp/jdk-19.tar.gz'
rm -f '/tmp/jdk-20.tar.gz'
rm -f '/tmp/jdk-21.tar.gz'
rm -f '/tmp/jdk-22.tar.gz'
rm -f '/tmp/jdk-22-jextract.tar.gz'
rm -f '/tmp/jdk-23.tar.gz'
rm -f '/tmp/jdk-23-valhalla.tar.gz'
rm -f '/tmp/jdk-24.tar.gz'
rm -f '/tmp/jdk-24-leyden.tar.gz'
rm -f '/tmp/jdk-24-loom.tar.gz'
rm -f '/tmp/graalvm-17.tar.gz'
rm -f '/tmp/graalvm-21.tar.gz'
rm -f '/tmp/graalvm-23.tar.gz'
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install (extract) Kotlin
# ------------------------------------------------------------------------------
echo 'Installing (extracting) Kotlin'
rm -rf '/usr/lib/kotlin/'
mkdir -p '/usr/lib/kotlin/'
unzip '/tmp/kotlin-compiler.zip' -d '/usr/lib/kotlin/'
rm -f '/tmp/kotlin-compiler.zip'
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install the dependencies required to build the statically linked native
# executable and other commands
# ------------------------------------------------------------------------------
echo 'Installing the dependencies required to build the statically linked native executable'
dnf config-manager --set-enabled ol9_codeready_builder
dnf install -y patch git-all gcc glibc-devel zlib-devel libstdc++-static make
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install hey, an HTTP load generator and ApacheBench (ab) replacement
# ------------------------------------------------------------------------------
echo 'Installing hey'
mkdir -p '/usr/local/sbin'
curl \
  --silent \
  --location \
  --output '/usr/local/sbin/hey' \
  'https://hey-release.s3.us-east-2.amazonaws.com/hey_linux_amd64'
chmod +x '/usr/local/sbin/hey'
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install the Docker Engine to build container images. Based on
# - https://docs.docker.com/engine/install/fedora/
# - https://stackoverflow.com/questions/70358656/rhel8-fedora-yum-dns-causes-cannot-download-repodata-repomd-xml-for-docker-ce
# ------------------------------------------------------------------------------
echo 'Installing Docker Engine'
dnf install -y dnf-plugins-core
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl start docker
chmod 666 '/var/run/docker.sock'
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install dive (https://github.com/wagoodman/dive) to analyse container images
# layers. Based on
#  - https://github.com/wagoodman/dive?tab=readme-ov-file#installation
# ------------------------------------------------------------------------------
echo 'Installing dive'
DIVE_VERSION=$(curl -sL "https://api.github.com/repos/wagoodman/dive/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
curl \
  --silent \
  --location \
  --output "/tmp/dive_${DIVE_VERSION}_linux_amd64.rpm" \
  "https://github.com/wagoodman/dive/releases/download/v${DIVE_VERSION}/dive_${DIVE_VERSION}_linux_amd64.rpm"
dnf install -y "/tmp/dive_${DIVE_VERSION}_linux_amd64.rpm"
rm -f "/tmp/dive_${DIVE_VERSION}_linux_amd64.rpm"
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install the Markdown Executor (me)
# https://github.com/albertattard/me
# ------------------------------------------------------------------------------
echo 'Installing Markdown Executor (me)'
sudo -i -u opc bash << 'EOF'
mkdir -p '/home/opc/.local/bin'
curl \
  --silent \
  --location \
  --output '/home/opc/.local/bin/me' \
  'https://github.com/albertattard/me/releases/latest/download/me'
chmod +x '/home/opc/.local/bin/me'
EOF
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install the Sociable Weaver (sw)
# https://github.com/albertattard/sociable-weaver
# ------------------------------------------------------------------------------
echo 'Installing Sociable Weaver (sw)'
sudo -i -u opc bash << 'EOF'
mkdir -p '/home/opc/.local/bin'
curl \
  --silent \
  --location \
  --output '/home/opc/.local/bin/sw' \
  'https://github.com/albertattard/sociable-weaver/releases/latest/download/sw'
chmod +x '/home/opc/.local/bin/sw'
EOF
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Set up Maven Toolchains
# ------------------------------------------------------------------------------
echo 'Setting up Maven toolchains'
sudo -i -u opc bash << 'EOF'
mkdir -p '/home/opc/.m2'
cat << 'B_EOF' > '/home/opc/.m2/toolchains.xml'
<?xml version="1.0" encoding="UTF-8"?>
<toolchains>
    <toolchain>
        <type>jdk</type>
        <provides>
            <version>1.8</version>
            <vendor>Oracle Corporation</vendor>
        </provides>
        <configuration>
            <jdkHome>/usr/lib/jvm/jdk-1.8</jdkHome>
        </configuration>
    </toolchain>
    <toolchain>
        <type>jdk</type>
        <provides>
            <version>epp</version>
            <vendor>Oracle Corporation</vendor>
        </provides>
        <configuration>
            <jdkHome>/usr/lib/jvm/jdk-1.8-perf</jdkHome>
        </configuration>
    </toolchain>
    <toolchain>
        <type>jdk</type>
        <provides>
            <version>9</version>
            <vendor>Oracle Corporation</vendor>
        </provides>
        <configuration>
            <jdkHome>/usr/lib/jvm/jdk-9</jdkHome>
        </configuration>
    </toolchain>
    <toolchain>
        <type>jdk</type>
        <provides>
            <version>10</version>
            <vendor>Oracle Corporation</vendor>
        </provides>
        <configuration>
            <jdkHome>/usr/lib/jvm/jdk-10</jdkHome>
        </configuration>
    </toolchain>
    <toolchain>
        <type>jdk</type>
        <provides>
            <version>11</version>
            <vendor>Oracle Corporation</vendor>
        </provides>
        <configuration>
            <jdkHome>/usr/lib/jvm/jdk-11</jdkHome>
        </configuration>
    </toolchain>
    <toolchain>
        <type>jdk</type>
        <provides>
            <version>12</version>
            <vendor>Oracle Corporation</vendor>
        </provides>
        <configuration>
            <jdkHome>/usr/lib/jvm/jdk-12</jdkHome>
        </configuration>
    </toolchain>
    <toolchain>
        <type>jdk</type>
        <provides>
            <version>13</version>
            <vendor>Oracle Corporation</vendor>
        </provides>
        <configuration>
            <jdkHome>/usr/lib/jvm/jdk-13</jdkHome>
        </configuration>
    </toolchain>
    <toolchain>
        <type>jdk</type>
        <provides>
            <version>14</version>
            <vendor>Oracle Corporation</vendor>
        </provides>
        <configuration>
            <jdkHome>/usr/lib/jvm/jdk-14</jdkHome>
        </configuration>
    </toolchain>
    <toolchain>
        <type>jdk</type>
        <provides>
            <version>15</version>
            <vendor>Oracle Corporation</vendor>
        </provides>
        <configuration>
            <jdkHome>/usr/lib/jvm/jdk-15</jdkHome>
        </configuration>
    </toolchain>
    <toolchain>
        <type>jdk</type>
        <provides>
            <version>16</version>
            <vendor>Oracle Corporation</vendor>
        </provides>
        <configuration>
            <jdkHome>/usr/lib/jvm/jdk-16</jdkHome>
        </configuration>
    </toolchain>
    <toolchain>
        <type>jdk</type>
        <provides>
            <version>17</version>
            <vendor>Oracle Corporation</vendor>
        </provides>
        <configuration>
            <jdkHome>/usr/lib/jvm/jdk-17</jdkHome>
        </configuration>
    </toolchain>
    <toolchain>
        <type>jdk</type>
        <provides>
            <version>18</version>
            <vendor>Oracle Corporation</vendor>
        </provides>
        <configuration>
            <jdkHome>/usr/lib/jvm/jdk-18</jdkHome>
        </configuration>
    </toolchain>
    <toolchain>
        <type>jdk</type>
        <provides>
            <version>19</version>
            <vendor>Oracle Corporation</vendor>
        </provides>
        <configuration>
            <jdkHome>/usr/lib/jvm/jdk-19</jdkHome>
        </configuration>
    </toolchain>
    <toolchain>
        <type>jdk</type>
        <provides>
            <version>20</version>
            <vendor>Oracle Corporation</vendor>
        </provides>
        <configuration>
            <jdkHome>/usr/lib/jvm/jdk-20</jdkHome>
        </configuration>
    </toolchain>
    <toolchain>
        <type>jdk</type>
        <provides>
            <version>21</version>
            <vendor>Oracle Corporation</vendor>
        </provides>
        <configuration>
            <jdkHome>/usr/lib/jvm/jdk-21</jdkHome>
        </configuration>
    </toolchain>
    <toolchain>
        <type>jdk</type>
        <provides>
            <version>22</version>
            <vendor>Oracle Corporation</vendor>
        </provides>
        <configuration>
            <jdkHome>/usr/lib/jvm/jdk-22</jdkHome>
        </configuration>
    </toolchain>
    <toolchain>
        <type>jdk</type>
        <provides>
            <version>22-jextract</version>
            <vendor>Oracle Corporation</vendor>
        </provides>
        <configuration>
            <jdkHome>/usr/lib/jvm/jdk-22-jextract</jdkHome>
        </configuration>
    </toolchain>
    <toolchain>
        <type>jdk</type>
        <provides>
            <version>23</version>
            <vendor>Oracle Corporation</vendor>
        </provides>
        <configuration>
            <jdkHome>/usr/lib/jvm/jdk-23</jdkHome>
        </configuration>
    </toolchain>
    <toolchain>
        <type>jdk</type>
        <provides>
            <version>23-valhalla</version>
            <vendor>Oracle Corporation</vendor>
        </provides>
        <configuration>
            <jdkHome>/usr/lib/jvm/jdk-23-valhalla</jdkHome>
        </configuration>
    </toolchain>
    <toolchain>
        <type>jdk</type>
        <provides>
            <version>24</version>
            <vendor>Oracle Corporation</vendor>
        </provides>
        <configuration>
            <jdkHome>/usr/lib/jvm/jdk-24</jdkHome>
        </configuration>
    </toolchain>
    <toolchain>
        <type>jdk</type>
        <provides>
            <version>24-leyden</version>
            <vendor>Oracle Corporation</vendor>
        </provides>
        <configuration>
            <jdkHome>/usr/lib/jvm/jdk-24-leyden</jdkHome>
        </configuration>
    </toolchain>
    <toolchain>
        <type>jdk</type>
        <provides>
            <version>24-loom</version>
            <vendor>Oracle Corporation</vendor>
        </provides>
        <configuration>
            <jdkHome>/usr/lib/jvm/jdk-24-loom</jdkHome>
        </configuration>
    </toolchain>
    <toolchain>
        <type>jdk</type>
        <provides>
            <version>graal17</version>
            <vendor>Oracle Corporation</vendor>
        </provides>
        <configuration>
            <jdkHome>/usr/lib/jvm/graalvm-17</jdkHome>
        </configuration>
    </toolchain>
    <toolchain>
        <type>jdk</type>
        <provides>
            <version>graal21</version>
            <vendor>Oracle Corporation</vendor>
        </provides>
        <configuration>
            <jdkHome>/usr/lib/jvm/graalvm-21</jdkHome>
        </configuration>
    </toolchain>
    <toolchain>
        <type>jdk</type>
        <provides>
            <version>graal23</version>
            <vendor>Oracle Corporation</vendor>
        </provides>
        <configuration>
            <jdkHome>/usr/lib/jvm/graalvm-23</jdkHome>
        </configuration>
    </toolchain>
</toolchains>
B_EOF
EOF
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install SDKMAN
# ------------------------------------------------------------------------------
echo 'Installing and configuring SDKMAN'
sudo -i -u opc bash << 'EOF'
curl --silent 'https://get.sdkman.io' | bash
source '/home/opc/.sdkman/bin/sdkman-init.sh'

mkdir -p '/home/opc/.sdkman/candidates/java'
ln -s '/usr/lib/jvm/jdk-1.8'         '/home/opc/.sdkman/candidates/java/1.8-oracle'
ln -s '/usr/lib/jvm/jdk-1.8-perf'    '/home/opc/.sdkman/candidates/java/epp-oracle'
ln -s '/usr/lib/jvm/jdk-9'           '/home/opc/.sdkman/candidates/java/9-oracle'
ln -s '/usr/lib/jvm/jdk-10'          '/home/opc/.sdkman/candidates/java/10-oracle'
ln -s '/usr/lib/jvm/jdk-11'          '/home/opc/.sdkman/candidates/java/11-oracle'
ln -s '/usr/lib/jvm/jdk-12'          '/home/opc/.sdkman/candidates/java/12-oracle'
ln -s '/usr/lib/jvm/jdk-13'          '/home/opc/.sdkman/candidates/java/13-oracle'
ln -s '/usr/lib/jvm/jdk-14'          '/home/opc/.sdkman/candidates/java/14-oracle'
ln -s '/usr/lib/jvm/jdk-15'          '/home/opc/.sdkman/candidates/java/15-oracle'
ln -s '/usr/lib/jvm/jdk-16'          '/home/opc/.sdkman/candidates/java/16-oracle'
ln -s '/usr/lib/jvm/jdk-17'          '/home/opc/.sdkman/candidates/java/17-oracle'
ln -s '/usr/lib/jvm/jdk-18'          '/home/opc/.sdkman/candidates/java/18-oracle'
ln -s '/usr/lib/jvm/jdk-19'          '/home/opc/.sdkman/candidates/java/19-oracle'
ln -s '/usr/lib/jvm/jdk-20'          '/home/opc/.sdkman/candidates/java/20-oracle'
ln -s '/usr/lib/jvm/jdk-21'          '/home/opc/.sdkman/candidates/java/21-oracle'
ln -s '/usr/lib/jvm/jdk-22'          '/home/opc/.sdkman/candidates/java/22-oracle'
ln -s '/usr/lib/jvm/jdk-22-jextract' '/home/opc/.sdkman/candidates/java/22-jextract'
ln -s '/usr/lib/jvm/jdk-23'          '/home/opc/.sdkman/candidates/java/23-oracle'
ln -s '/usr/lib/jvm/jdk-23-valhalla' '/home/opc/.sdkman/candidates/java/23-valhalla'
ln -s '/usr/lib/jvm/jdk-24'          '/home/opc/.sdkman/candidates/java/24-oracle'
ln -s '/usr/lib/jvm/jdk-24-leyden'   '/home/opc/.sdkman/candidates/java/24-leyden'
ln -s '/usr/lib/jvm/jdk-24-loom'     '/home/opc/.sdkman/candidates/java/24-loom'
ln -s '/usr/lib/jvm/graalvm-17'      '/home/opc/.sdkman/candidates/java/17-graal'
ln -s '/usr/lib/jvm/graalvm-21'      '/home/opc/.sdkman/candidates/java/21-graal'
ln -s '/usr/lib/jvm/graalvm-23'      '/home/opc/.sdkman/candidates/java/23-graal'

sdk default java 21-oracle

mkdir -p '/home/opc/.bashrc.d'
cat << 'B_EOF' > '/home/opc/.bashrc.d/java'
export JAVA_1_8_HOME='/usr/lib/jvm/jdk-1.8'
export JAVA_EPP_HOME='/usr/lib/jvm/jdk-1.8-perf'
export JAVA_9_HOME='/usr/lib/jvm/jdk-9'
export JAVA_10_HOME='/usr/lib/jvm/jdk-10'
export JAVA_11_HOME='/usr/lib/jvm/jdk-11'
export JAVA_12_HOME='/usr/lib/jvm/jdk-12'
export JAVA_13_HOME='/usr/lib/jvm/jdk-13'
export JAVA_14_HOME='/usr/lib/jvm/jdk-14'
export JAVA_15_HOME='/usr/lib/jvm/jdk-15'
export JAVA_16_HOME='/usr/lib/jvm/jdk-16'
export JAVA_17_HOME='/usr/lib/jvm/jdk-17'
export JAVA_18_HOME='/usr/lib/jvm/jdk-18'
export JAVA_19_HOME='/usr/lib/jvm/jdk-19'
export JAVA_20_HOME='/usr/lib/jvm/jdk-20'
export JAVA_21_HOME='/usr/lib/jvm/jdk-21'
export JAVA_22_HOME='/usr/lib/jvm/jdk-22'
export JAVA_22_JEXTRACT_HOME='/usr/lib/jvm/jdk-22-jextract'
export JAVA_23_HOME='/usr/lib/jvm/jdk-23'
export JAVA_23_VALHALLA_HOME='/usr/lib/jvm/jdk-23-valhalla'
export JAVA_24_HOME='/usr/lib/jvm/jdk-24'
export JAVA_24_LEYDEN_HOME='/usr/lib/jvm/jdk-24-leyden'
export JAVA_24_LOOM_HOME='/usr/lib/jvm/jdk-24-loom'
export GRAAL_17_HOME='/usr/lib/jvm/graalvm-17'
export GRAAL_21_HOME='/usr/lib/jvm/graalvm-21'
export GRAAL_23_HOME='/usr/lib/jvm/graalvm-23'

export JAVA_HOME='/home/opc/.sdkman/candidates/java/current'
PATH="${PATH}:/home/opc/.sdkman/candidates/java/current/bin"

alias    java8='sdk use java 1.8-oracle'
alias      epp='sdk use java epp-oracle'
alias    java9='sdk use java 9-oracle'
alias   java10='sdk use java 10-oracle'
alias   java11='sdk use java 11-oracle'
alias   java12='sdk use java 12-oracle'
alias   java13='sdk use java 13-oracle'
alias   java14='sdk use java 14-oracle'
alias   java15='sdk use java 15-oracle'
alias   java16='sdk use java 16-oracle'
alias   java17='sdk use java 17-oracle'
alias   java18='sdk use java 18-oracle'
alias   java19='sdk use java 19-oracle'
alias   java20='sdk use java 20-oracle'
alias   java21='sdk use java 21-oracle'
alias   java22='sdk use java 22-oracle'
alias jextract='sdk use java 22-jextract'
alias   java23='sdk use java 23-oracle'
alias valhalla='sdk use java 23-valhalla'
alias   java24='sdk use java 24-oracle'
alias   leyden='sdk use java 24-leyden'
alias     loom='sdk use java 24-loom'
alias  graal17="sdk use java 17-graal"
alias  graal21="sdk use java 21-graal"
alias  graal23="sdk use java 23-graal"
B_EOF

mkdir -p '/home/opc/.sdkman/candidates/kotlin'
ln -s '/usr/lib/kotlin/kotlinc' '/home/opc/.sdkman/candidates/kotlin/2.0.0'

sdk default kotlin 2.0.0

cat << 'B_EOF' > '/home/opc/.bashrc.d/kotlin'
PATH="${PATH}:/home/opc/.sdkman/candidates/kotlin/current/bin"
B_EOF
EOF
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install MUSL required to build the static native executables.
# See: https://docs.oracle.com/en/graalvm/enterprise/21/docs/reference-manual/native-image/StaticImages/#static-and-mostly-static-images
# ------------------------------------------------------------------------------
echo 'Installing MUSL'
mkdir -p '/usr/lib/musl'
tar --extract --file '/tmp/x86_64-linux-musl-native.tgz' --directory '/usr/lib/musl' --strip-components 1

sudo -i -u opc bash << 'EOF'
mkdir -p '/home/opc/.bashrc.d'
cat << 'B_EOF' > '/home/opc/.bashrc.d/graal'
export TOOLCHAIN_DIR='/usr/lib/musl'
export CC="${TOOLCHAIN_DIR}/bin/gcc"
PATH="${PATH}:/usr/lib/musl/bin"
B_EOF
EOF

rm -f '/tmp/x86_64-linux-musl-native.tgz'
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install zlib (https://zlib.net), a compression library that will be complied
# and included into the GraalVM MUSL GCC toolchain.
# ------------------------------------------------------------------------------
echo 'Installing zlib'
mkdir -p '/tmp/zlib'
tar --extract --file '/tmp/zlib-1.3.1.tar.gz' --directory '/tmp/zlib' --strip-components 1

(cd '/tmp/zlib';
./configure --prefix='/usr/lib/musl' --static;
make;
make install;)

for GRAALVM_PATH in '/usr/lib/jvm/graalvm-17' '/usr/lib/jvm/graalvm-21' '/usr/lib/jvm/graalvm-23'
do
  mkdir -p "${GRAALVM_PATH}/lib/static/linux-amd64/musl"
  cp '/tmp/zlib/libz.a' "${GRAALVM_PATH}/lib/static/linux-amd64/musl"
done

rm -rf '/tmp/zlib'
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Create the working directory
# ------------------------------------------------------------------------------
echo 'Creating the working directory'
sudo -i -u opc bash << 'EOF'
mkdir -p '/home/opc/workspace'
EOF
# ------------------------------------------------------------------------------
