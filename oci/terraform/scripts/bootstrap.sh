#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------------------------
# Tests the provided link and fails if the link is not reachable
# ------------------------------------------------------------------------------
check_reachable_link() {
    local link="${1}"

    curl --silent --show-error --fail --head "${link}" > /dev/null
}

require_reachable_link() {
    local link="${1}"
    local message="${2:-Link: ${link} is not reachable}"

    if ! check_reachable_link "${link}"; then
        echo "${message}" >&2
        exit 1
    fi
}

retry_require_reachable_link() {
    local link="${1}"
    local message="${2:-Link: ${link} is not reachable}"
    local attempts="${3:-5}"
    local sleep_seconds="${4:-60}"
    local attempt

    for (( attempt=1; attempt<=attempts; attempt++ )); do
        if check_reachable_link "${link}"; then
            return 0
        fi

        if (( attempt < attempts )); then
            echo "Link not reachable yet, retrying in ${sleep_seconds}s (${attempt}/${attempts})" >&2
            sleep "${sleep_seconds}"
        fi
    done

    echo "${message}" >&2
    exit 1
}
# ------------------------------------------------------------------------------


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
retry_require_reachable_link "${BINARIES_PRE_AUTHENTICATED_LINK}/ok" 'Cannot access the binaries using the provided pre authenticated link'
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Upgrade the system to the current release (takes several minutes to run)
# Note that the updates will vary depending on when this command executes
# ------------------------------------------------------------------------------
# dnf upgrade --refresh -y
# dnf upgrade -y openssh openssh-server openssh-clients
# systemctl restart sshd
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
# Enable the additional Oracle Linux CodeReady Builder repository, then refresh
# DNF metadata cache so package lookups/installations use the latest repo index.
# ------------------------------------------------------------------------------
echo 'Installing bootstrap prerequisites'
dnf install -y dnf-plugins-core

dnf config-manager --set-enabled "ol10_codeready_builder"
dnf clean all
dnf makecache
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install the dependencies required to build the statically linked native
# executable and other commands
# ------------------------------------------------------------------------------
echo 'Installing the dependencies required to build the statically linked native executable'
dnf install -y patch git-all gcc glibc-devel zlib-devel libstdc++-static make unzip zip
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Oracle releases four critical patch updates per year, and these versions of
# Java need to be updated every three months. Their values are grouped here for
# convenience, so that you don't have to go to multiple places to update a
# version
# ------------------------------------------------------------------------------
# https://www.oracle.com/java/technologies/downloads/#java8
# https://www.oracle.com/a/tech/docs/8u481checksum.html
JAVA_1_8_BINARY_FILE='jdk-8u481-linux-x64.tar.gz'
JAVA_1_8_BINARY_SHA256='ab2220d1e8ce7226ae601aacba4d22c56d9007e843ee470ad84cc98dbcb7cd92'

# https://www.oracle.com/java/technologies/downloads/#jepp
# https://www.oracle.com/a/tech/docs/8u481checksum.html
JAVA_1_8_PERF_BINARY_FILE='jdk-8u481-perf-linux-x64.tar.gz'
JAVA_1_8_PERF_BINARY_SHA256='a468e4e0d91796b02fef67c9e0d998379a027ea88daeb7cf76e9b7b30cc50e37'

# https://www.oracle.com/java/technologies/downloads/#java11
# https://www.oracle.com/a/tech/docs/11-0-30-checksum.html
JAVA_11_BINARY_FILE='jdk-11.0.30_linux-x64_bin.tar.gz'
JAVA_11_BINARY_SHA256='850a02b784ade48f2dc059bbd095947ad4c69e15ddd878d166e7f38c71d6109b'

# https://www.oracle.com/java/technologies/downloads/#java17
# https://www.oracle.com/a/tech/docs/17-0-18-checksum.html
JAVA_17_BINARY_FILE="jdk-17.0.18_linux-x64_bin.tar.gz"
JAVA_17_BINARY_SHA256='3b47cf7886438a73065a18cbd1c8d091836571669b3e7922c255c79855ad3c5e'

# https://www.oracle.com/java/technologies/downloads/#java21
# https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.tar.gz.sha256
JAVA_21_BINARY_FILE='jdk-21.0.10_linux-x64_bin.tar.gz'
JAVA_21_BINARY_SHA256='773eff7191d996d3b6ce3a99c21ce69cf2d836fd07277106313732a098d4309a'

# https://www.oracle.com/java/technologies/downloads/#java25
# https://download.oracle.com/java/25/latest/jdk-25_linux-x64_bin.tar.gz.sha256
JAVA_25_BINARY_FILE='jdk-25.0.2_linux-x64_bin.tar.gz'
JAVA_25_BINARY_SHA256='505fdcb1f172b4aad23415f0584912cff90b7d902adc5f1593894b4a8cbf7c39'

# https://jdk.java.net/loom/
# https://download.java.net/java/early_access/loom/1/openjdk-25-loom+1-11_linux-x64_bin.tar.gz.sha256
JAVA_25_LOOM_BINARY_FILE='openjdk-25-loom+1-11_linux-x64_bin.tar.gz'
JAVA_25_LOOM_BINARY_SHA256='0f526d5f25cc9bcb2a7fe449c9f9853d835e4e1bda4fcb998a8d7b17db43d885'

# https://jdk.java.net/jextract/
# https://download.java.net/java/early_access/jextract/25/2/openjdk-25-jextract+2-4_linux-x64_bin.tar.gz.sha256
JAVA_25_JEXTRACT_BINARY_FILE='openjdk-25-jextract+2-4_linux-x64_bin.tar.gz'
JAVA_25_JEXTRACT_BINARY_SHA256='d0cc481abc1adb16fb9514e1c5e0bfc08d38c29228bece667fb5054ceaffaa42'

# https://jdk.java.net/26/
# https://download.java.net/java/early_access/jdk26/32/GPL/openjdk-26-ea+32_linux-x64_bin.tar.gz.sha256
JAVA_26_BINARY_FILE='openjdk-26-ea+32_linux-x64_bin.tar.gz'
JAVA_26_BINARY_SHA256='99e956807a500a396bc799f5b450e79c295bccece78ae9ca67f3e75646d3a099'

# https://jdk.java.net/valhalla/
# https://download.java.net/java/early_access/valhalla/26/1/openjdk-26-jep401ea2+1-1_linux-x64_bin.tar.gz.sha256
JAVA_26_VALHALLA_BINARY_FILE='openjdk-26-jep401ea2+1-1_linux-x64_bin.tar.gz'
JAVA_26_VALHALLA_BINARY_SHA256='27d12e7ed51b0a9e94c6356adb4c42a50a8861031e1bc833b3f6b7a3212bed55'

# https://jdk.java.net/valhalla/
# https://download.java.net/java/early_access/leyden/1/openjdk-26-leydenpremain+1_linux-x64_bin.tar.gz.sha256
JAVA_26_LEYDEN_BINARY_FILE='openjdk-26-leydenpremain+1_linux-x64_bin.tar.gz'
JAVA_26_LEYDEN_BINARY_SHA256='866efe47f88fbe0b50dc0ba7e2ea501e0d760deacfa2b1d473fa991c285001dd'

# https://www.oracle.com/downloads/graalvm-downloads.html
GRAALVM_25_BINARY_FILE='graalvm-jdk-25.0.2_linux-x64_bin.tar.gz'
GRAALVM_25_BINARY_SHA256='af545b1bc12ecd24a5ba95e2370da2163e87c4cf13991a482d5b176bf4165c12'
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Verify the links before proceeding
# ------------------------------------------------------------------------------
echo 'Verifying the links'
require_reachable_link "${BINARIES_PRE_AUTHENTICATED_LINK}/${JAVA_1_8_BINARY_FILE}"
require_reachable_link "${BINARIES_PRE_AUTHENTICATED_LINK}/${JAVA_1_8_PERF_BINARY_FILE}"
require_reachable_link "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-9.0.4_linux-x64_bin.tar.gz"
require_reachable_link "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-10.0.2_linux-x64_bin.tar.gz"
require_reachable_link "${BINARIES_PRE_AUTHENTICATED_LINK}/${JAVA_11_BINARY_FILE}"
require_reachable_link "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-12.0.2_linux-x64_bin.tar.gz"
require_reachable_link "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-13.0.2_linux-x64_bin.tar.gz"
require_reachable_link "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-14.0.2_linux-x64_bin.tar.gz"
require_reachable_link "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-15.0.2_linux-x64_bin.tar.gz"
require_reachable_link "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-16.0.2_linux-x64_bin.tar.gz"
require_reachable_link "${BINARIES_PRE_AUTHENTICATED_LINK}/${JAVA_17_BINARY_FILE}"
require_reachable_link "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-18.0.2.1_linux-x64_bin.tar.gz"
require_reachable_link "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-19.0.2_linux-x64_bin.tar.gz"
require_reachable_link "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-20.0.2_linux-x64_bin.tar.gz"
require_reachable_link "${BINARIES_PRE_AUTHENTICATED_LINK}/${JAVA_21_BINARY_FILE}"
require_reachable_link "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-22.0.2_linux-x64_bin.tar.gz"
require_reachable_link "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-23.0.2_linux-x64_bin.tar.gz"
require_reachable_link "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-24.0.2_linux-x64_bin.tar.gz"
require_reachable_link "${BINARIES_PRE_AUTHENTICATED_LINK}/${JAVA_25_BINARY_FILE}"
require_reachable_link "${BINARIES_PRE_AUTHENTICATED_LINK}/${JAVA_25_LOOM_BINARY_FILE}"
require_reachable_link "${BINARIES_PRE_AUTHENTICATED_LINK}/${JAVA_25_JEXTRACT_BINARY_FILE}"
require_reachable_link "${BINARIES_PRE_AUTHENTICATED_LINK}/${JAVA_26_BINARY_FILE}"
require_reachable_link "${BINARIES_PRE_AUTHENTICATED_LINK}/${JAVA_26_LEYDEN_BINARY_FILE}"
require_reachable_link "${BINARIES_PRE_AUTHENTICATED_LINK}/${JAVA_26_VALHALLA_BINARY_FILE}"
require_reachable_link "${BINARIES_PRE_AUTHENTICATED_LINK}/${GRAALVM_25_BINARY_FILE}"
require_reachable_link "${BINARIES_PRE_AUTHENTICATED_LINK}/kotlin-compiler-2.3.0.zip"
require_reachable_link "${BINARIES_PRE_AUTHENTICATED_LINK}/zlib-1.3.1.tar.gz"
require_reachable_link "${BINARIES_PRE_AUTHENTICATED_LINK}/x86_64-linux-musl-native.tgz"
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
curl --silent --show-error --fail --location --output '/tmp/jdk-1.8.tar.gz'               "${BINARIES_PRE_AUTHENTICATED_LINK}/${JAVA_1_8_BINARY_FILE}"
curl --silent --show-error --fail --location --output '/tmp/jdk-1.8-perf.tar.gz'          "${BINARIES_PRE_AUTHENTICATED_LINK}/${JAVA_1_8_PERF_BINARY_FILE}"
curl --silent --show-error --fail --location --output '/tmp/jdk-9.tar.gz'                 "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-9.0.4_linux-x64_bin.tar.gz"
curl --silent --show-error --fail --location --output '/tmp/jdk-10.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-10.0.2_linux-x64_bin.tar.gz"
curl --silent --show-error --fail --location --output '/tmp/jdk-11.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/${JAVA_11_BINARY_FILE}"
curl --silent --show-error --fail --location --output '/tmp/jdk-12.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-12.0.2_linux-x64_bin.tar.gz"
curl --silent --show-error --fail --location --output '/tmp/jdk-13.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-13.0.2_linux-x64_bin.tar.gz"
curl --silent --show-error --fail --location --output '/tmp/jdk-14.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-14.0.2_linux-x64_bin.tar.gz"
curl --silent --show-error --fail --location --output '/tmp/jdk-15.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-15.0.2_linux-x64_bin.tar.gz"
curl --silent --show-error --fail --location --output '/tmp/jdk-16.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-16.0.2_linux-x64_bin.tar.gz"
curl --silent --show-error --fail --location --output '/tmp/jdk-17.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/${JAVA_17_BINARY_FILE}"
curl --silent --show-error --fail --location --output '/tmp/jdk-18.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-18.0.2.1_linux-x64_bin.tar.gz"
curl --silent --show-error --fail --location --output '/tmp/jdk-19.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-19.0.2_linux-x64_bin.tar.gz"
curl --silent --show-error --fail --location --output '/tmp/jdk-20.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-20.0.2_linux-x64_bin.tar.gz"
curl --silent --show-error --fail --location --output '/tmp/jdk-21.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/${JAVA_21_BINARY_FILE}"
curl --silent --show-error --fail --location --output '/tmp/jdk-22.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-22.0.2_linux-x64_bin.tar.gz"
curl --silent --show-error --fail --location --output '/tmp/jdk-23.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-23.0.2_linux-x64_bin.tar.gz"
curl --silent --show-error --fail --location --output '/tmp/jdk-24.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-24.0.2_linux-x64_bin.tar.gz"
curl --silent --show-error --fail --location --output '/tmp/jdk-25.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/${JAVA_25_BINARY_FILE}"
curl --silent --show-error --fail --location --output '/tmp/jdk-25-loom.tar.gz'           "${BINARIES_PRE_AUTHENTICATED_LINK}/${JAVA_25_LOOM_BINARY_FILE}"
curl --silent --show-error --fail --location --output '/tmp/jdk-25-jextract.tar.gz'       "${BINARIES_PRE_AUTHENTICATED_LINK}/${JAVA_25_JEXTRACT_BINARY_FILE}"
curl --silent --show-error --fail --location --output '/tmp/jdk-26.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/${JAVA_26_BINARY_FILE}"
curl --silent --show-error --fail --location --output '/tmp/jdk-26-leyden.tar.gz'         "${BINARIES_PRE_AUTHENTICATED_LINK}/${JAVA_26_LEYDEN_BINARY_FILE}"
curl --silent --show-error --fail --location --output '/tmp/jdk-26-valhalla.tar.gz'       "${BINARIES_PRE_AUTHENTICATED_LINK}/${JAVA_26_VALHALLA_BINARY_FILE}"
curl --silent --show-error --fail --location --output '/tmp/graalvm-25.tar.gz'            "${BINARIES_PRE_AUTHENTICATED_LINK}/${GRAALVM_25_BINARY_FILE}"
curl --silent --show-error --fail --location --output '/tmp/kotlin-compiler.zip'          "${BINARIES_PRE_AUTHENTICATED_LINK}/kotlin-compiler-2.3.0.zip"
curl --silent --show-error --fail --location --output '/tmp/zlib-1.3.1.tar.gz'            "${BINARIES_PRE_AUTHENTICATED_LINK}/zlib-1.3.1.tar.gz"
curl --silent --show-error --fail --location --output '/tmp/x86_64-linux-musl-native.tgz' "${BINARIES_PRE_AUTHENTICATED_LINK}/x86_64-linux-musl-native.tgz"
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
echo '12d7553d06b5cacf88b26cad4a8ba83cabe79646f1defb1b7fd029f3356d0922 /tmp/jdk-23.tar.gz'                | sha256sum --check
echo "5f9f7c4ca2a6cef0f18a27465e1be81bddd8653218f450a329a2afc9bf2a1dd8 /tmp/jdk-24.tar.gz"                | sha256sum --check
echo "${JAVA_25_BINARY_SHA256} /tmp/jdk-25.tar.gz"                                                        | sha256sum --check
echo "${JAVA_25_LOOM_BINARY_SHA256} /tmp/jdk-25-loom.tar.gz"                                              | sha256sum --check
echo "${JAVA_25_JEXTRACT_BINARY_SHA256} /tmp/jdk-25-jextract.tar.gz"                                      | sha256sum --check
echo "${JAVA_26_BINARY_SHA256} /tmp/jdk-26.tar.gz"                                                        | sha256sum --check
echo "${JAVA_26_LEYDEN_BINARY_SHA256} /tmp/jdk-26-leyden.tar.gz"                                          | sha256sum --check
echo "${JAVA_26_VALHALLA_BINARY_SHA256} /tmp/jdk-26-valhalla.tar.gz"                                      | sha256sum --check
echo "${GRAALVM_25_BINARY_SHA256} /tmp/graalvm-25.tar.gz"                                                 | sha256sum --check
echo 'ea16ab1cab29d419bf41b60ecc0e305d449fa661d9c05fbcc5b2a6672505456a /tmp/kotlin-compiler.zip'          | sha256sum --check
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
mkdir -p '/usr/lib/jvm/jdk-23'
mkdir -p '/usr/lib/jvm/jdk-24'
mkdir -p '/usr/lib/jvm/jdk-25'
mkdir -p '/usr/lib/jvm/jdk-25-loom'
mkdir -p '/usr/lib/jvm/jdk-25-jextract'
mkdir -p '/usr/lib/jvm/jdk-26'
mkdir -p '/usr/lib/jvm/jdk-26-leyden'
mkdir -p '/usr/lib/jvm/jdk-26-valhalla'
mkdir -p '/usr/lib/jvm/graalvm-25'

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
tar --extract --file '/tmp/jdk-23.tar.gz'          --directory '/usr/lib/jvm/jdk-23'          --strip-components 1
tar --extract --file '/tmp/jdk-24.tar.gz'          --directory '/usr/lib/jvm/jdk-24'          --strip-components 1
tar --extract --file '/tmp/jdk-25.tar.gz'          --directory '/usr/lib/jvm/jdk-25'          --strip-components 1
tar --extract --file '/tmp/jdk-25-loom.tar.gz'     --directory '/usr/lib/jvm/jdk-25-loom'     --strip-components 1
tar --extract --file '/tmp/jdk-25-jextract.tar.gz' --directory '/usr/lib/jvm/jdk-25-jextract' --strip-components 1
tar --extract --file '/tmp/jdk-26.tar.gz'          --directory '/usr/lib/jvm/jdk-26'          --strip-components 1
tar --extract --file '/tmp/jdk-26-leyden.tar.gz'   --directory '/usr/lib/jvm/jdk-26-leyden'   --strip-components 1
tar --extract --file '/tmp/jdk-26-valhalla.tar.gz' --directory '/usr/lib/jvm/jdk-26-valhalla' --strip-components 1
tar --extract --file '/tmp/graalvm-25.tar.gz'      --directory '/usr/lib/jvm/graalvm-25'      --strip-components 1

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
rm -f '/tmp/jdk-23.tar.gz'
rm -f '/tmp/jdk-24.tar.gz'
rm -f '/tmp/jdk-25.tar.gz'
rm -f '/tmp/jdk-25-loom.tar.gz'
rm -f '/tmp/jdk-25-jextract.tar.gz'
rm -f '/tmp/jdk-26.tar.gz'
rm -f '/tmp/jdk-26-leyden.tar.gz'
rm -f '/tmp/jdk-26-valhalla.tar.gz'
rm -f '/tmp/graalvm-25.tar.gz'
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
# Install Rust
# ------------------------------------------------------------------------------
echo 'Installing Rust'
dnf install -y rust cargo
rustc --version
cargo --version
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install hey, an HTTP load generator and ApacheBench (ab) replacement
# ------------------------------------------------------------------------------
echo 'Installing hey'
mkdir -p '/usr/local/sbin'
curl \
  --ipv4 \
  --silent \
  --show-error \
  --fail \
  --location \
  --retry 5 \
  --retry-delay 10 \
  --retry-connrefused \
  --output '/usr/local/sbin/hey' \
  'https://storage.googleapis.com/hey-releases/hey_linux_amd64'
chmod +x '/usr/local/sbin/hey'
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install JMeter
# ------------------------------------------------------------------------------
echo 'Installing JMeter'
curl \
  --silent \
  --show-error \
  --fail \
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
# Install the Python
# ------------------------------------------------------------------------------
echo 'Installing Python'
dnf install -y python3-pip python3
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install the Falcon Heartbeat (required by security)
# ------------------------------------------------------------------------------
echo 'Install the Falcon Heartbeat (required by security)'
echo 'See: https://confluence.oraclecorp.com/confluence/display/NIT/Falcon+Heartbeat+Findings+Resolution+-+Scripts'
curl --fail \
  --location \
  --silent \
  --show-error \
  --output '/tmp/install_falcon.py' 'https://objectstorage.us-ashburn-1.oraclecloud.com/p/wpj0M57XjIImf1jZcEsGhqdP1ZyUY27tr1eL6NAqsXVpapFp468aredx6whaWinG/n/orasenatdpltintegration03/b/FalconSupport-donotdelete/o/install_falcon.py'
python3 '/tmp/install_falcon.py'
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install Podman (a docker runtime)
# - https://oracle-base.com/articles/linux/podman-install-on-oracle-linux-ol9
# ------------------------------------------------------------------------------
echo 'Installing Podman'

# Podman needs zstd because modern container images and storage use zstd
# compression for better speed and efficiency. Without it, Podman may fail to
# pull or handle some images.
dnf install -y zstd

dnf install -y podman
dnf install -y podman-docker
dnf install -y buildah skopeo

# To suppress the message:
#   'Emulate Docker CLI using podman. Create /etc/containers/nodocker to quiet msg.'
touch '/etc/containers/nodocker'
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install Podman Compose
# Version source:
# - https://pypi.org/project/podman-compose/
# ------------------------------------------------------------------------------
echo 'Installing Podman Compose'
sudo -i -u opc bash << 'EOF'
PODMAN_COMPOSE_VERSION='1.5.0'
pip3 install --user "podman-compose==${PODMAN_COMPOSE_VERSION}"
EOF
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
# Version source:
# - https://github.com/wagoodman/dive/releases
# Checksum source:
# - dive_${DIVE_VERSION}_checksums.txt from the matching GitHub release
# ------------------------------------------------------------------------------
echo 'Installing dive'
DIVE_VERSION='0.13.1'
DIVE_RPM="dive_${DIVE_VERSION}_linux_amd64.rpm"
DIVE_SHA256='17d399388dc87c06d8b63917c256e702c0ec5c5158039a73ed20f191bc4758b1'

curl \
  --silent \
  --show-error \
  --fail \
  --location \
  --output "/tmp/${DIVE_RPM}" \
  "https://github.com/wagoodman/dive/releases/download/v${DIVE_VERSION}/${DIVE_RPM}"

echo "${DIVE_SHA256} /tmp/${DIVE_RPM}" | sha256sum --check
dnf install -y "/tmp/${DIVE_RPM}"
rm -f "/tmp/${DIVE_RPM}"
dive --version
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install GNU Debugger (GDB)
# ------------------------------------------------------------------------------
echo 'Installing GDB'
dnf install -y gdb gdb-gdbserver
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install XQ (https://github.com/sibprogrammer/xq) to format XML files
# Version source:
# - https://github.com/sibprogrammer/xq/releases
# Checksum source:
# - checksums.txt from the matching GitHub release
# ------------------------------------------------------------------------------
echo 'Installing xq'
XQ_VERSION='1.4.0'
XQ_ARCHIVE="xq_${XQ_VERSION}_linux_amd64.tar.gz"
XQ_SHA256='467e83864c3cf70a3a0754cd08070d21fa4b5fbccb8eb10ac3d7ea499fa48217'

curl \
  --silent \
  --show-error \
  --fail \
  --location \
  --output "/tmp/${XQ_ARCHIVE}" \
  "https://github.com/sibprogrammer/xq/releases/download/v${XQ_VERSION}/${XQ_ARCHIVE}"

echo "${XQ_SHA256} /tmp/${XQ_ARCHIVE}" | sha256sum --check
tar --extract --gzip --file "/tmp/${XQ_ARCHIVE}" --directory /tmp xq
install --mode 0755 /tmp/xq /usr/local/bin/xq
rm -f "/tmp/${XQ_ARCHIVE}" /tmp/xq
/usr/local/bin/xq --version
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install Syft (https://github.com/anchore/syft) to extract SBOM from native
# executables
# Version source:
# - https://github.com/anchore/syft/releases
# Checksum source:
# - syft_${SYFT_VERSION}_checksums.txt from the matching GitHub release
# ------------------------------------------------------------------------------
echo 'Installing Syft'
SYFT_VERSION='1.42.2'
SYFT_RPM="syft_${SYFT_VERSION}_linux_amd64.rpm"
SYFT_SHA256='9f0fea41666db4d3c76f04dce3a6537ddceaf34c419aad90af534bca62e85f5c'

curl \
  --silent \
  --show-error \
  --fail \
  --location \
  --output "/tmp/${SYFT_RPM}" \
  "https://github.com/anchore/syft/releases/download/v${SYFT_VERSION}/${SYFT_RPM}"

echo "${SYFT_SHA256} /tmp/${SYFT_RPM}" | sha256sum --check
dnf install -y "/tmp/${SYFT_RPM}"
rm -f "/tmp/${SYFT_RPM}"
syft --version
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install grype (https://github.com/anchore/grype) to scan for vulnerabilities
# Version source:
# - https://github.com/anchore/grype/releases
# Checksum source:
# - grype_${GRYPE_VERSION}_checksums.txt from the matching GitHub release
# ------------------------------------------------------------------------------
echo 'Installing grype'
GRYPE_VERSION='0.104.4'
GRYPE_RPM="grype_${GRYPE_VERSION}_linux_amd64.rpm"
GRYPE_SHA256='979c12a9a7aeb6b6d7cfd24ed8ebfc01be6dbe96dc6508df11d9914b70b362e6'

curl \
  --silent \
  --show-error \
  --fail \
  --location \
  --output "/tmp/${GRYPE_RPM}" \
  "https://github.com/anchore/grype/releases/download/v${GRYPE_VERSION}/${GRYPE_RPM}"

echo "${GRYPE_SHA256} /tmp/${GRYPE_RPM}" | sha256sum --check
dnf install -y "/tmp/${GRYPE_RPM}"
rm -f "/tmp/${GRYPE_RPM}"
grype version
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install the Ollama
# Version source:
# - https://github.com/ollama/ollama/releases
# Checksum source:
# - the sha256 value published next to ollama-linux-amd64.tgz in the matching
#   GitHub release
# ------------------------------------------------------------------------------
echo 'Installing Ollama'
OLLAMA_VERSION='0.13.5'
OLLAMA_ARCHIVE='ollama-linux-amd64.tgz'
OLLAMA_SHA256='41fb93ff8be35e4d2d22bafd1c42b487efb15b766076d976766bd1ee4db3f8e2'

curl \
  --silent \
  --show-error \
  --fail \
  --location \
  --output "/tmp/${OLLAMA_ARCHIVE}" \
  "https://github.com/ollama/ollama/releases/download/v${OLLAMA_VERSION}/${OLLAMA_ARCHIVE}"

echo "${OLLAMA_SHA256} /tmp/${OLLAMA_ARCHIVE}" | sha256sum --check
tar --extract --gzip --file "/tmp/${OLLAMA_ARCHIVE}" --directory /usr
rm -f "/tmp/${OLLAMA_ARCHIVE}"

if ! id -u ollama >/dev/null 2>&1; then
  useradd --system --user-group --create-home --home-dir /usr/share/ollama --shell /bin/false ollama
fi

if getent group render >/dev/null 2>&1; then
  usermod -a -G render ollama
fi

if getent group video >/dev/null 2>&1; then
  usermod -a -G video ollama
fi

usermod -a -G ollama opc

cat << 'EOF' > /etc/systemd/system/ollama.service
[Unit]
Description=Ollama Service
After=network-online.target

[Service]
ExecStart=/usr/bin/ollama serve
User=ollama
Group=ollama
Restart=always
RestartSec=3
Environment="HOME=/usr/share/ollama"

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now ollama
ollama --version
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install the ripgrep (rg)
# Version source:
# - https://github.com/BurntSushi/ripgrep/releases
# Checksum source:
# - ripgrep-<version>-x86_64-unknown-linux-musl.tar.gz.sha256 from the matching
#   GitHub release
# ------------------------------------------------------------------------------
echo 'Installing ripgrep (rg)'
RIPGREP_VERSION='14.1.1'
RIPGREP_ARCHIVE="ripgrep-${RIPGREP_VERSION}-x86_64-unknown-linux-musl.tar.gz"
RIPGREP_SHA256='4cf9f2741e6c465ffdb7c26f38056a59e2a2544b51f7cc128ef28337eeae4d8e'

curl \
  --silent \
  --show-error \
  --fail \
  --location \
  --output "/tmp/${RIPGREP_ARCHIVE}" \
  "https://github.com/BurntSushi/ripgrep/releases/download/${RIPGREP_VERSION}/${RIPGREP_ARCHIVE}"

echo "${RIPGREP_SHA256} /tmp/${RIPGREP_ARCHIVE}" | sha256sum --check
tar --extract --gzip --file "/tmp/${RIPGREP_ARCHIVE}" --directory /tmp "ripgrep-${RIPGREP_VERSION}-x86_64-unknown-linux-musl/rg"
install --mode 0755 "/tmp/ripgrep-${RIPGREP_VERSION}-x86_64-unknown-linux-musl/rg" /usr/local/bin/rg
rm -rf "/tmp/${RIPGREP_ARCHIVE}" "/tmp/ripgrep-${RIPGREP_VERSION}-x86_64-unknown-linux-musl"
/usr/local/bin/rg --version
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install the Sociable Weaver (sw)
# Source repository:
# - https://github.com/albertattard/sw
# ------------------------------------------------------------------------------
echo 'Installing Sociable Weaver (sw)'
sudo -i -u opc bash << 'EOF'
curl \
  --silent \
  --show-error \
  --fail \
  --location \
  --proto '=https' \
  --tlsv1.2 \
  https://sh.rustup.rs | \
  sh -s -- -y --profile minimal --default-toolchain 1.94.1
source "$HOME/.cargo/env"

rustup component add clippy rustfmt

rm -rf '/home/opc/sw'
git clone 'https://github.com/albertattard/sw' '/home/opc/sw'

cd '/home/opc/sw'
cargo build --release

mkdir --parents '/home/opc/.local/bin'
install --mode 0755 '/home/opc/sw/target/release/sw' '/home/opc/.local/bin/sw'
rm -rf '/home/opc/sw'
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
            <version>25-jextract</version>
            <vendor>Oracle Corporation</vendor>
        </provides>
        <configuration>
            <jdkHome>/usr/lib/jvm/jdk-25-jextract</jdkHome>
        </configuration>
    </toolchain>
    <toolchain>
        <type>jdk</type>
        <provides>
            <version>26</version>
            <vendor>Oracle Corporation</vendor>
        </provides>
        <configuration>
            <jdkHome>/usr/lib/jvm/jdk-26</jdkHome>
        </configuration>
    </toolchain>
    <toolchain>
        <type>jdk</type>
        <provides>
            <version>26-leyden</version>
            <vendor>Oracle Corporation</vendor>
        </provides>
        <configuration>
            <jdkHome>/usr/lib/jvm/jdk-26-leyden</jdkHome>
        </configuration>
    </toolchain>
    <toolchain>
        <type>jdk</type>
        <provides>
            <version>26-valhalla</version>
            <vendor>Oracle Corporation</vendor>
        </provides>
        <configuration>
            <jdkHome>/usr/lib/jvm/jdk-26-valhalla</jdkHome>
        </configuration>
    </toolchain>
    <toolchain>
        <type>jdk</type>
        <provides>
            <version>graal25</version>
            <vendor>Oracle Corporation</vendor>
        </provides>
        <configuration>
            <jdkHome>/usr/lib/jvm/graalvm-25</jdkHome>
        </configuration>
    </toolchain>
</toolchains>
B_EOF
EOF
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install SDKMAN
# Installation source:
# - https://sdkman.io/install
# We rely on the official installer here.
# ------------------------------------------------------------------------------
echo 'Installing and configuring SDKMAN'
sudo -i -u opc bash << 'EOF'
rm -rf '/home/opc/.sdkman'

curl --silent --show-error --fail --location 'https://get.sdkman.io' | bash

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
ln -s '/usr/lib/jvm/jdk-23'          '/home/opc/.sdkman/candidates/java/23-oracle'
ln -s '/usr/lib/jvm/jdk-24'          '/home/opc/.sdkman/candidates/java/24-oracle'
ln -s '/usr/lib/jvm/jdk-25'          '/home/opc/.sdkman/candidates/java/25-oracle'
ln -s '/usr/lib/jvm/jdk-25-loom'     '/home/opc/.sdkman/candidates/java/25-loom'
ln -s '/usr/lib/jvm/jdk-25-jextract' '/home/opc/.sdkman/candidates/java/25-jextract'
ln -s '/usr/lib/jvm/jdk-26'          '/home/opc/.sdkman/candidates/java/26-oracle'
ln -s '/usr/lib/jvm/jdk-26-leyden'   '/home/opc/.sdkman/candidates/java/26-leyden'
ln -s '/usr/lib/jvm/jdk-26-valhalla' '/home/opc/.sdkman/candidates/java/26-valhalla'
ln -s '/usr/lib/jvm/graalvm-25'      '/home/opc/.sdkman/candidates/java/25-graal'

sdk default java 25-oracle

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
export JAVA_23_HOME='/usr/lib/jvm/jdk-23'
export JAVA_24_HOME='/usr/lib/jvm/jdk-24'
export JAVA_25_HOME='/usr/lib/jvm/jdk-25'
export JAVA_25_LOOM_HOME='/usr/lib/jvm/jdk-25-loom'
export JAVA_25_JEXTRACT_HOME='/usr/lib/jvm/jdk-25-jextract'
export JAVA_26_HOME='/usr/lib/jvm/jdk-26'
export JAVA_26_LEYDEN_HOME='/usr/lib/jvm/jdk-26-leyden'
export JAVA_26_VALHALLA_HOME='/usr/lib/jvm/jdk-26-valhalla'
export GRAAL_25_HOME='/usr/lib/jvm/graalvm-25'

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
alias   java23='sdk use java 23-oracle'
alias   java24='sdk use java 24-oracle'
alias   java25='sdk use java 25-oracle'
alias     loom='sdk use java 25-loom'
alias jextract='sdk use java 25-jextract'
alias   java26='sdk use java 26-oracle'
alias   leyden='sdk use java 26-leyden'
alias valhalla='sdk use java 26-valhalla'
alias  graal25="sdk use java 25-graal"
B_EOF

mkdir -p '/home/opc/.sdkman/candidates/kotlin'
ln -s '/usr/lib/kotlin/kotlinc' '/home/opc/.sdkman/candidates/kotlin/2.3.0'

sdk default kotlin 2.3.0

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

for GRAALVM_PATH in '/usr/lib/jvm/graalvm-25'
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
