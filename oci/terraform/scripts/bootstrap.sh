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
# Allow applications to be accessed from the internet on port 8080. The firewall
# denies access from the internet on port 8080. Also, note that the application
# needs to use the TCP/IPv4 over the TCP/IPv6. This can be achieved using the
# java.net.preferIPv4Stack=true option as shown next:
# java -jar -Djava.net.preferIPv4Stack=true application.jar
# ------------------------------------------------------------------------------
# firewall-cmd --permanent --zone=public --add-port=8080/tcp
# firewall-cmd --reload
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Oracle releases four critical patch updates per year, and these versions of
# Java need to be updated every three months. Their values are grouped here for
# convenience, so that you don't have to go to multiple places to update a
# version
# ------------------------------------------------------------------------------
# https://www.oracle.com/java/technologies/downloads/#java8
# https://www.oracle.com/a/tech/docs/8u451checksum.html
JAVA_1_8_BINARY_FILE='jdk-8u451-linux-x64.tar.gz'
JAVA_1_8_BINARY_SHA256='4b945be38cc9b44ddb1bdd4a7d28fdbee3cabb410575e20cdbe157d2bf5b886d'

# https://www.oracle.com/java/technologies/downloads/#jepp
# https://www.oracle.com/a/tech/docs/8u451checksum.html
JAVA_1_8_PERF_BINARY_FILE='jdk-8u451-perf-linux-x64.tar.gz'
JAVA_1_8_PERF_BINARY_SHA256='6be533fce84dd0f5519270b9e3a0e8b2b189abde8a29b911e8553a323a916f8a'

# https://www.oracle.com/java/technologies/downloads/#java11
# https://www.oracle.com/a/tech/docs/11-0-27-checksum.html
JAVA_11_BINARY_FILE='jdk-11.0.27_linux-x64_bin.tar.gz'
JAVA_11_BINARY_SHA256='3d2e2b6cabf5172c0ccdcdddc8dd9d3d5c7152b8536530a956568c3d7981793b'

# https://www.oracle.com/java/technologies/downloads/#java17
# https://www.oracle.com/a/tech/docs/17-0-15-checksum.html
JAVA_17_BINARY_FILE="jdk-17.0.15_linux-x64_bin.tar.gz"
JAVA_17_BINARY_SHA256='2dfef3016808b20270aa7324964395330a2a410d1f7145ffc20e3a65d5af0e13'

# https://www.oracle.com/java/technologies/downloads/#java21
# https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.tar.gz.sha256
JAVA_21_BINARY_FILE='jdk-21.0.7_linux-x64_bin.tar.gz'
JAVA_21_BINARY_SHA256='267b10b14b4e5fada19aca3be3b961ce4f81f1bd3ffcd070e90a5586106125eb'

# https://jdk.java.net/jextract/
# https://download.java.net/java/early_access/jextract/22/6/openjdk-22-jextract+6-47_linux-aarch64_bin.tar.gz.sha256
JAVA_22_JEXTRACT_BINARY_FILE='openjdk-22-jextract+6-47_linux-x64_bin.tar.gz'
JAVA_22_JEXTRACT_BINARY_SHA256='a6a42d5b5f4bff119455daadd1ccec9389b2554aea3342f391577843769cc7ec'

# https://jdk.java.net/valhalla/
# https://download.java.net/java/early_access/valhalla/1/openjdk-23-valhalla+1-90_linux-x64_bin.tar.gz.sha256
JAVA_23_VALHALLA_BINARY_FILE='openjdk-23-valhalla+1-90_linux-x64_bin.tar.gz'
JAVA_23_VALHALLA_BINARY_SHA256='5235afaf5ecc86f2237458cf40f8ed965939372f606edbd0fc46e1ee2e69f5f5'

# https://www.oracle.com/java/technologies/downloads/#java24
# https://download.oracle.com/java/24/latest/jdk-24_linux-x64_bin.tar.gz.sha256
JAVA_24_BINARY_FILE='jdk-24.0.1_linux-x64_bin.tar.gz'
JAVA_24_BINARY_SHA256='07096b29c65feb393972870347f36021be421a74c1800be468b3c19f04e8e943'

# https://jdk.java.net/25/
# https://download.java.net/java/early_access/jdk25/18/GPL/openjdk-25-ea+18_linux-x64_bin.tar.gz.sha256
JAVA_25_BINARY_FILE='openjdk-25-ea+18_linux-x64_bin.tar.gz'
JAVA_25_BINARY_SHA256='ee6ce5bbdd9156680b3022019f79622afcb37c06de135a7ad1a5fe893f78eb61'

# https://jdk.java.net/loom/
# https://download.java.net/java/early_access/loom/1/openjdk-25-loom+1-11_linux-x64_bin.tar.gz.sha256
JAVA_25_LOOM_BINARY_FILE='openjdk-25-loom+1-11_linux-x64_bin.tar.gz'
JAVA_25_LOOM_BINARY_SHA256='0f526d5f25cc9bcb2a7fe449c9f9853d835e4e1bda4fcb998a8d7b17db43d885'

# https://www.oracle.com/java/technologies/downloads/#graalvmjava17
# https://www.oracle.com/a/tech/docs/graalvm17-0-15-checksum.html
GRAALVM_17_BINARY_FILE='graalvm-jdk-17.0.15_linux-x64_bin.tar.gz'
GRAALVM_17_BINARY_SHA256='30a65dd0ac609031c89d897be4c613dfd40374fc20a3eca858c6d6f6b96c329e'

# https://www.oracle.com/java/technologies/downloads/#graalvmjava21
# https://download.oracle.com/graalvm/21/latest/graalvm-jdk-21_linux-x64_bin.tar.gz.sha256
GRAALVM_21_BINARY_FILE='graalvm-jdk-21.0.7_linux-x64_bin.tar.gz'
GRAALVM_21_BINARY_SHA256='67ac85876b4402ce253bbce85debd1ac515c650530ef0ed2b64c7d754078e821'

# https://www.oracle.com/java/technologies/downloads/#graalvmjava24
# https://download.oracle.com/graalvm/24/latest/graalvm-jdk-24_linux-x64_bin.tar.gz.sha256
GRAALVM_24_BINARY_FILE='graalvm-jdk-24.0.1_linux-x64_bin.tar.gz'
GRAALVM_24_BINARY_SHA256='757389c22d3448d4d02d5cf78fbff1da2d6c6e2fdfb4ebc96acab08830641ce6'
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
curl --silent --location --output '/tmp/jdk-22-jextract.tar.gz'       "${BINARIES_PRE_AUTHENTICATED_LINK}/${JAVA_22_JEXTRACT_BINARY_FILE}"
curl --silent --location --output '/tmp/jdk-23.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-23.0.2_linux-x64_bin.tar.gz"
curl --silent --location --output '/tmp/jdk-23-valhalla.tar.gz'       "${BINARIES_PRE_AUTHENTICATED_LINK}/${JAVA_23_VALHALLA_BINARY_FILE}"
curl --silent --location --output '/tmp/jdk-24.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/${JAVA_24_BINARY_FILE}"
curl --silent --location --output '/tmp/jdk-24-leyden.tar.gz'         "${BINARIES_PRE_AUTHENTICATED_LINK}/openjdk-24-leyden+2-8_linux-x64_bin.tar.gz"
curl --silent --location --output '/tmp/jdk-25.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/${JAVA_25_BINARY_FILE}"
curl --silent --location --output '/tmp/jdk-25-loom.tar.gz'           "${BINARIES_PRE_AUTHENTICATED_LINK}/${JAVA_25_LOOM_BINARY_FILE}"
curl --silent --location --output '/tmp/graalvm-17.tar.gz'            "${BINARIES_PRE_AUTHENTICATED_LINK}/${GRAALVM_17_BINARY_FILE}"
curl --silent --location --output '/tmp/graalvm-21.tar.gz'            "${BINARIES_PRE_AUTHENTICATED_LINK}/${GRAALVM_21_BINARY_FILE}"
curl --silent --location --output '/tmp/graalvm-23.tar.gz'            "${BINARIES_PRE_AUTHENTICATED_LINK}/graalvm-jdk-23.0.2_linux-x64_bin.tar.gz"
curl --silent --location --output '/tmp/graalvm-24.tar.gz'            "${BINARIES_PRE_AUTHENTICATED_LINK}/${GRAALVM_24_BINARY_FILE}"
curl --silent --location --output '/tmp/kotlin-compiler.zip'          "${BINARIES_PRE_AUTHENTICATED_LINK}/kotlin-compiler-2.1.0.zip"
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
echo "${JAVA_22_JEXTRACT_BINARY_SHA256} /tmp/jdk-22-jextract.tar.gz"                                      | sha256sum --check
echo '12d7553d06b5cacf88b26cad4a8ba83cabe79646f1defb1b7fd029f3356d0922 /tmp/jdk-23.tar.gz'                | sha256sum --check
echo "${JAVA_23_VALHALLA_BINARY_SHA256} /tmp/jdk-23-valhalla.tar.gz"                                      | sha256sum --check
echo "${JAVA_24_BINARY_SHA256} /tmp/jdk-24.tar.gz"                                                        | sha256sum --check
echo '7a6f9f5a602377b882e647ae9312706c6873afc582d2612681e6fbe9e122a088 /tmp/jdk-24-leyden.tar.gz'         | sha256sum --check
echo "${JAVA_25_BINARY_SHA256} /tmp/jdk-25.tar.gz"                                                        | sha256sum --check
echo "${JAVA_25_LOOM_BINARY_SHA256} /tmp/jdk-25-loom.tar.gz"                                              | sha256sum --check
echo "${GRAALVM_17_BINARY_SHA256} /tmp/graalvm-17.tar.gz"                                                 | sha256sum --check
echo "${GRAALVM_21_BINARY_SHA256} /tmp/graalvm-21.tar.gz"                                                 | sha256sum --check
echo 'db09b1fe18b83f338af9b3291443774b3170d9eba17538ce2ee39c5e6d601dfc /tmp/graalvm-23.tar.gz'            | sha256sum --check
echo "${GRAALVM_24_BINARY_SHA256} /tmp/graalvm-24.tar.gz"                                                 | sha256sum --check
echo 'b6698d5728ad8f9edcdd01617d638073191d8a03139cc538a391b4e3759ad297 /tmp/kotlin-compiler.zip'          | sha256sum --check
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
mkdir -p '/usr/lib/jvm/jdk-25'
mkdir -p '/usr/lib/jvm/jdk-25-loom'
mkdir -p '/usr/lib/jvm/graalvm-17'
mkdir -p '/usr/lib/jvm/graalvm-21'
mkdir -p '/usr/lib/jvm/graalvm-23'
mkdir -p '/usr/lib/jvm/graalvm-24'

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
tar --extract --file '/tmp/jdk-25.tar.gz'          --directory '/usr/lib/jvm/jdk-25'          --strip-components 1
tar --extract --file '/tmp/jdk-25-loom.tar.gz'     --directory '/usr/lib/jvm/jdk-25-loom'     --strip-components 1
tar --extract --file '/tmp/graalvm-17.tar.gz'      --directory '/usr/lib/jvm/graalvm-17'      --strip-components 1
tar --extract --file '/tmp/graalvm-21.tar.gz'      --directory '/usr/lib/jvm/graalvm-21'      --strip-components 1
tar --extract --file '/tmp/graalvm-23.tar.gz'      --directory '/usr/lib/jvm/graalvm-23'      --strip-components 1
tar --extract --file '/tmp/graalvm-24.tar.gz'      --directory '/usr/lib/jvm/graalvm-24'      --strip-components 1

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
rm -f '/tmp/jdk-25.tar.gz'
rm -f '/tmp/jdk-25-loom.tar.gz'
rm -f '/tmp/graalvm-17.tar.gz'
rm -f '/tmp/graalvm-21.tar.gz'
rm -f '/tmp/graalvm-23.tar.gz'
rm -f '/tmp/graalvm-24.tar.gz'
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
# Install JMeter
# ------------------------------------------------------------------------------
echo 'Installing JMeter'
curl \
  --silent \
  --location \
  --output '/tmp/apache-jmeter-5.6.3.tgz' \
  'https://downloads.apache.org//jmeter/binaries/apache-jmeter-5.6.3.tgz'

mkdir -p '/opt/jmeter'
tar --extract --file '/tmp/apache-jmeter-5.6.3.tgz' --directory '/opt/jmeter' --strip-components 1

sudo -i -u opc bash << 'EOF'
mkdir -p '/home/opc/.bashrc.d'
cat << 'B_EOF' > '/home/opc/.bashrc.d/jmeter'
PATH="${PATH}:/opt/jmeter/bin"
B_EOF
EOF
rm '/tmp/apache-jmeter-5.6.3.tgz'
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install Podman (a docker runtime)
# - https://oracle-base.com/articles/linux/podman-install-on-oracle-linux-ol9
# ------------------------------------------------------------------------------
echo 'Installing Podman'
dnf install -y podman
dnf install -y podman-docker
dnf install -y buildah skopeo

# To suppress the message:
#   'Emulate Docker CLI using podman. Create /etc/containers/nodocker to quiet msg.'
touch '/etc/containers/nodocker'
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install the Docker Engine to build container images. Based on
# - https://docs.docker.com/engine/install/fedora/
# - https://stackoverflow.com/questions/70358656/rhel8-fedora-yum-dns-causes-cannot-download-repodata-repomd-xml-for-docker-ce
# ------------------------------------------------------------------------------
# echo 'Installing Docker Engine'
# dnf install -y dnf-plugins-core
# dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
# dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
# systemctl start docker
# chmod 666 '/var/run/docker.sock'
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
# Install GNU Debugger (GDB)
# ------------------------------------------------------------------------------
echo 'Installing GDB'
dnf install -y gdb gdb-gdbserver
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install XQ (https://github.com/sibprogrammer/xq) to format XML files
# ------------------------------------------------------------------------------
echo 'Installing xq'
curl -sSL https://bit.ly/install-xq | bash
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install Syft (https://github.com/anchore/syft) to extract SBOM from native
# executables
# ------------------------------------------------------------------------------
echo 'Installing Syft'
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install grype (https://github.com/anchore/grype) to scan for vulnerabilities
# ------------------------------------------------------------------------------
echo 'Installing grype'
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin
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
            <version>25</version>
            <vendor>Oracle Corporation</vendor>
        </provides>
        <configuration>
            <jdkHome>/usr/lib/jvm/jdk-25</jdkHome>
        </configuration>
    </toolchain>
    <toolchain>
        <type>jdk</type>
        <provides>
            <version>25-loom</version>
            <vendor>Oracle Corporation</vendor>
        </provides>
        <configuration>
            <jdkHome>/usr/lib/jvm/jdk-25-loom</jdkHome>
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
    <toolchain>
        <type>jdk</type>
        <provides>
            <version>graal24</version>
            <vendor>Oracle Corporation</vendor>
        </provides>
        <configuration>
            <jdkHome>/usr/lib/jvm/graalvm-24</jdkHome>
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
ln -s '/usr/lib/jvm/jdk-25'          '/home/opc/.sdkman/candidates/java/25-oracle'
ln -s '/usr/lib/jvm/jdk-25-loom'     '/home/opc/.sdkman/candidates/java/25-loom'
ln -s '/usr/lib/jvm/graalvm-17'      '/home/opc/.sdkman/candidates/java/17-graal'
ln -s '/usr/lib/jvm/graalvm-21'      '/home/opc/.sdkman/candidates/java/21-graal'
ln -s '/usr/lib/jvm/graalvm-23'      '/home/opc/.sdkman/candidates/java/23-graal'
ln -s '/usr/lib/jvm/graalvm-24'      '/home/opc/.sdkman/candidates/java/24-graal'

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
export JAVA_25_HOME='/usr/lib/jvm/jdk-25'
export JAVA_25_LOOM_HOME='/usr/lib/jvm/jdk-25-loom'
export GRAAL_17_HOME='/usr/lib/jvm/graalvm-17'
export GRAAL_21_HOME='/usr/lib/jvm/graalvm-21'
export GRAAL_23_HOME='/usr/lib/jvm/graalvm-23'
export GRAAL_24_HOME='/usr/lib/jvm/graalvm-24'

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
alias   java25='sdk use java 25-oracle'
alias     loom='sdk use java 25-loom'
alias  graal17="sdk use java 17-graal"
alias  graal21="sdk use java 21-graal"
alias  graal23="sdk use java 23-graal"
alias  graal24="sdk use java 24-graal"
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
