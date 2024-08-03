#!/bin/bash

BINARIES_PRE_AUTHENTICATED_LINK="$1"

set -e

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
/usr/libexec/oci-growfs --yes
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Download the binaries using the provided Pre-Authenticated link. Kindly note
# that while some of these binaries are freely available others are not. Do not
# make the Per-Authenticated link publicly available.
#
# For more information or require additional help, please speak to Albert Attard
# (albert.attard@oracle.com).
# ------------------------------------------------------------------------------
curl --silent --location --output '/tmp/jdk-1.8.tar.gz'               "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-8u421-linux-x64.tar.gz"
curl --silent --location --output '/tmp/jdk-1.8-perf.tar.gz'          "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-8u421-perf-linux-x64.tar.gz"
curl --silent --location --output '/tmp/jdk-9.tar.gz'                 "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-9.0.4_linux-x64_bin.tar.gz"
curl --silent --location --output '/tmp/jdk-10.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-10.0.2_linux-x64_bin.tar.gz"
curl --silent --location --output '/tmp/jdk-11.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-11.0.24_linux-x64_bin.tar.gz"
curl --silent --location --output '/tmp/jdk-12.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-12.0.2_linux-x64_bin.tar.gz"
curl --silent --location --output '/tmp/jdk-13.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-13.0.2_linux-x64_bin.tar.gz"
curl --silent --location --output '/tmp/jdk-14.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-14.0.2_linux-x64_bin.tar.gz"
curl --silent --location --output '/tmp/jdk-15.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-15.0.2_linux-x64_bin.tar.gz"
curl --silent --location --output '/tmp/jdk-16.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-16.0.2_linux-x64_bin.tar.gz"
curl --silent --location --output '/tmp/jdk-17.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-17.0.12_linux-x64_bin.tar.gz"
curl --silent --location --output '/tmp/jdk-18.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-18.0.2.1_linux-x64_bin.tar.gz"
curl --silent --location --output '/tmp/jdk-19.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-19.0.2_linux-x64_bin.tar.gz"
curl --silent --location --output '/tmp/jdk-20.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-20.0.2_linux-x64_bin.tar.gz"
curl --silent --location --output '/tmp/jdk-21.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-21.0.4_linux-x64_bin.tar.gz"
curl --silent --location --output '/tmp/jdk-22.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/jdk-22.0.2_linux-x64_bin.tar.gz"
curl --silent --location --output '/tmp/jdk-23.tar.gz'                "${BINARIES_PRE_AUTHENTICATED_LINK}/openjdk-23-ea+35_linux-x64_bin.tar.gz"
curl --silent --location --output '/tmp/graalvm-17.tar.gz'            "${BINARIES_PRE_AUTHENTICATED_LINK}/graalvm-jdk-17.0.12_linux-x64_bin.tar.gz"
curl --silent --location --output '/tmp/graalvm-21.tar.gz'            "${BINARIES_PRE_AUTHENTICATED_LINK}/graalvm-jdk-21.0.4_linux-x64_bin.tar.gz"
curl --silent --location --output '/tmp/graalvm-22.tar.gz'            "${BINARIES_PRE_AUTHENTICATED_LINK}/graalvm-jdk-22.0.2_linux-x64_bin.tar.gz"
curl --silent --location --output '/tmp/kotlin-compiler.zip'          "${BINARIES_PRE_AUTHENTICATED_LINK}/kotlin-compiler-2.0.0.zip"
curl --silent --location --output '/tmp/zlib-1.3.1.tar.gz'            "${BINARIES_PRE_AUTHENTICATED_LINK}/zlib-1.3.1.tar.gz"
curl --silent --location --output '/tmp/x86_64-linux-musl-native.tgz' "${BINARIES_PRE_AUTHENTICATED_LINK}/x86_64-linux-musl-native.tgz"
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Verify all the downloaded binaries
# ------------------------------------------------------------------------------
echo '92bfdee599c334f641de2d4ae08a4a082b966cb19b88d13d48b8486f80727b58 /tmp/jdk-1.8.tar.gz'               | sha256sum --check
echo '796666f8071202d85ad5d8013845d36045fd69b44135ebbeb76dffced3724c00 /tmp/jdk-1.8-perf.tar.gz'          | sha256sum --check
echo '90c4ea877e816e3440862cfa36341bc87d05373d53389ec0f2d54d4e8c95daa2 /tmp/jdk-9.tar.gz'                 | sha256sum --check
echo '6633c20d53c50c20835364d0f3e172e0cbbce78fff81867488f22a6298fa372b /tmp/jdk-10.tar.gz'                | sha256sum --check
echo 'f50fdec8a48a9b360d30ecc29af36f63f04f0b70ec829d3bf821e4e361682791 /tmp/jdk-11.tar.gz'                | sha256sum --check
echo '2dde6fda89a4ec6e6560ed464e917861c9e40bf576e7a64856dafc55abaaff51 /tmp/jdk-12.tar.gz'                | sha256sum --check
echo 'e2214a723d611b4a781641061a24ca6024f2c57dbd9f75ca9d857cad87d9475f /tmp/jdk-13.tar.gz'                | sha256sum --check
echo 'cb811a86926cc0f529d16bec7bd2e25fb73e75125bbd1775cdb9a96998593dde /tmp/jdk-14.tar.gz'                | sha256sum --check
echo '54b29a3756671fcb4b6116931e03e86645632ec39361bc16ad1aaa67332c7c61 /tmp/jdk-15.tar.gz'                | sha256sum --check
echo '630e3e56c58f45db3788343ce842756d5a5a401a63884242cc6a141071285a62 /tmp/jdk-16.tar.gz'                | sha256sum --check
echo '311f1448312ecab391fe2a1b2ac140d6e1c7aea6fbf08416b466a58874f2b40f /tmp/jdk-17.tar.gz'                | sha256sum --check
echo 'cd905013facbb5c2b5354165cc372e327259de4991c28f31c7d4231dbf638934 /tmp/jdk-18.tar.gz'                | sha256sum --check
echo '59f26ace2727d0e9b24fc09d5a48393c9dbaffe04c932a02938e8d6d582058c6 /tmp/jdk-19.tar.gz'                | sha256sum --check
echo '499b59be8e3613c223e76f101598d7c28dc04b8e154d860edf2ed05980c67526 /tmp/jdk-20.tar.gz'                | sha256sum --check
echo 'dc0d14d5cf1b44e02832a7e85d0d5eb1f4623dc389a2b7fb3d21089b84fc7eb1 /tmp/jdk-21.tar.gz'                | sha256sum --check
echo 'cbc13aaa2618659f44cb261f820f179832d611f0df35dd30a78d7dea6d717858 /tmp/jdk-22.tar.gz'                | sha256sum --check
echo '5387c8da8acb4261265c12bb46cea856c248d70bf9d64164019b74ed96545655 /tmp/jdk-23.tar.gz'                | sha256sum --check
echo 'b6f3dace24cf1960ec790216f4c86f00d4f43df64e4e8b548f6382f04894713f /tmp/graalvm-17.tar.gz'            | sha256sum --check
echo '30307941ab59e58f3f0f55e694885a930531a58f1917d07267b2439f6549605e /tmp/graalvm-21.tar.gz'            | sha256sum --check
echo '1881aa2c431b0506ecb170439832b053b757368d7109bd422298ca23e7939cd0 /tmp/graalvm-22.tar.gz'            | sha256sum --check
echo 'ef578730976154fd2c5968d75af8c2703b3de84a78dffe913f670326e149da3b /tmp/kotlin-compiler.zip'          | sha256sum --check
echo '9a93b2b7dfdac77ceba5a558a580e74667dd6fede4585b91eefb60f03b72df23 /tmp/zlib-1.3.1.tar.gz'            | sha256sum --check
echo 'd587e1fadefaad60687dd1dcb9b278e7b587e12cb1dc48cae42a9f52bb8613a7 /tmp/x86_64-linux-musl-native.tgz' | sha256sum --check
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install (extract) Oracle Java and Oracle GraalVM
# ------------------------------------------------------------------------------
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
mkdir -p '/usr/lib/jvm/graalvm-17'
mkdir -p '/usr/lib/jvm/graalvm-21'
mkdir -p '/usr/lib/jvm/graalvm-22'

tar --extract --file '/tmp/jdk-1.8.tar.gz'      --directory '/usr/lib/jvm/jdk-1.8'      --strip-components 1
tar --extract --file '/tmp/jdk-1.8-perf.tar.gz' --directory '/usr/lib/jvm/jdk-1.8-perf' --strip-components 1
tar --extract --file '/tmp/jdk-9.tar.gz'        --directory '/usr/lib/jvm/jdk-9'        --strip-components 1
tar --extract --file '/tmp/jdk-10.tar.gz'       --directory '/usr/lib/jvm/jdk-10'       --strip-components 1
tar --extract --file '/tmp/jdk-11.tar.gz'       --directory '/usr/lib/jvm/jdk-11'       --strip-components 1
tar --extract --file '/tmp/jdk-12.tar.gz'       --directory '/usr/lib/jvm/jdk-12'       --strip-components 1
tar --extract --file '/tmp/jdk-13.tar.gz'       --directory '/usr/lib/jvm/jdk-13'       --strip-components 1
tar --extract --file '/tmp/jdk-14.tar.gz'       --directory '/usr/lib/jvm/jdk-14'       --strip-components 1
tar --extract --file '/tmp/jdk-15.tar.gz'       --directory '/usr/lib/jvm/jdk-15'       --strip-components 1
tar --extract --file '/tmp/jdk-16.tar.gz'       --directory '/usr/lib/jvm/jdk-16'       --strip-components 1
tar --extract --file '/tmp/jdk-17.tar.gz'       --directory '/usr/lib/jvm/jdk-17'       --strip-components 1
tar --extract --file '/tmp/jdk-18.tar.gz'       --directory '/usr/lib/jvm/jdk-18'       --strip-components 1
tar --extract --file '/tmp/jdk-19.tar.gz'       --directory '/usr/lib/jvm/jdk-19'       --strip-components 1
tar --extract --file '/tmp/jdk-20.tar.gz'       --directory '/usr/lib/jvm/jdk-20'       --strip-components 1
tar --extract --file '/tmp/jdk-21.tar.gz'       --directory '/usr/lib/jvm/jdk-21'       --strip-components 1
tar --extract --file '/tmp/jdk-22.tar.gz'       --directory '/usr/lib/jvm/jdk-22'       --strip-components 1
tar --extract --file '/tmp/jdk-23.tar.gz'       --directory '/usr/lib/jvm/jdk-23'       --strip-components 1
tar --extract --file '/tmp/graalvm-17.tar.gz'   --directory '/usr/lib/jvm/graalvm-17'   --strip-components 1
tar --extract --file '/tmp/graalvm-21.tar.gz'   --directory '/usr/lib/jvm/graalvm-21'   --strip-components 1
tar --extract --file '/tmp/graalvm-22.tar.gz'   --directory '/usr/lib/jvm/graalvm-22'   --strip-components 1

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
rm -f '/tmp/graalvm-17.tar.gz'
rm -f '/tmp/graalvm-21.tar.gz'
rm -f '/tmp/graalvm-22.tar.gz'
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install (extract) Kotlin
# ------------------------------------------------------------------------------
rm -rf '/usr/lib/kotlin/'
mkdir -p '/usr/lib/kotlin/'
unzip '/tmp/kotlin-compiler.zip' -d '/usr/lib/kotlin/'
rm -f '/tmp/kotlin-compiler.zip'
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install the dependencies required to build the statically linked native
# executable
# ------------------------------------------------------------------------------
dnf config-manager --set-enabled ol9_codeready_builder
dnf install -y git-all gcc glibc-devel zlib-devel libstdc++-static make
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install hey, an HTTP load generator and ApacheBench (ab) replacement
# ------------------------------------------------------------------------------
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
# Setup Maven Toolchains
# ------------------------------------------------------------------------------
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
            <version>graal22</version>
            <vendor>Oracle Corporation</vendor>
        </provides>
        <configuration>
            <jdkHome>/usr/lib/jvm/graalvm-22</jdkHome>
        </configuration>
    </toolchain>
</toolchains>
B_EOF
EOF
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install SDKMAN
# ------------------------------------------------------------------------------
sudo -i -u opc bash << 'EOF'
curl --silent 'https://get.sdkman.io' | bash
source '/home/opc/.sdkman/bin/sdkman-init.sh'

mkdir -p '/home/opc/.sdkman/candidates/java'
ln -s '/usr/lib/jvm/jdk-1.8'      '/home/opc/.sdkman/candidates/java/1.8-oracle'
ln -s '/usr/lib/jvm/jdk-1.8-perf' '/home/opc/.sdkman/candidates/java/epp-oracle'
ln -s '/usr/lib/jvm/jdk-9'        '/home/opc/.sdkman/candidates/java/9-oracle'
ln -s '/usr/lib/jvm/jdk-10'       '/home/opc/.sdkman/candidates/java/10-oracle'
ln -s '/usr/lib/jvm/jdk-11'       '/home/opc/.sdkman/candidates/java/11-oracle'
ln -s '/usr/lib/jvm/jdk-12'       '/home/opc/.sdkman/candidates/java/12-oracle'
ln -s '/usr/lib/jvm/jdk-13'       '/home/opc/.sdkman/candidates/java/13-oracle'
ln -s '/usr/lib/jvm/jdk-14'       '/home/opc/.sdkman/candidates/java/14-oracle'
ln -s '/usr/lib/jvm/jdk-15'       '/home/opc/.sdkman/candidates/java/15-oracle'
ln -s '/usr/lib/jvm/jdk-16'       '/home/opc/.sdkman/candidates/java/16-oracle'
ln -s '/usr/lib/jvm/jdk-17'       '/home/opc/.sdkman/candidates/java/17-oracle'
ln -s '/usr/lib/jvm/jdk-18'       '/home/opc/.sdkman/candidates/java/18-oracle'
ln -s '/usr/lib/jvm/jdk-19'       '/home/opc/.sdkman/candidates/java/19-oracle'
ln -s '/usr/lib/jvm/jdk-20'       '/home/opc/.sdkman/candidates/java/20-oracle'
ln -s '/usr/lib/jvm/jdk-21'       '/home/opc/.sdkman/candidates/java/21-oracle'
ln -s '/usr/lib/jvm/jdk-22'       '/home/opc/.sdkman/candidates/java/22-oracle'
ln -s '/usr/lib/jvm/jdk-23'       '/home/opc/.sdkman/candidates/java/23-oracle'
ln -s '/usr/lib/jvm/graalvm-17'   '/home/opc/.sdkman/candidates/java/17-graal'
ln -s '/usr/lib/jvm/graalvm-21'   '/home/opc/.sdkman/candidates/java/21-graal'
ln -s '/usr/lib/jvm/graalvm-22'   '/home/opc/.sdkman/candidates/java/22-graal'

sdk default java 21-oracle

mkdir -p '/home/opc/.bashrc.d'
cat << 'B_EOF' > '/home/opc/.bashrc.d/java'
export JAVA_HOME='/home/opc/.sdkman/candidates/java/current'
PATH="${PATH}:/home/opc/.sdkman/candidates/java/current/bin"

alias   java8='sdk use java 1.8-oracle'
alias     epp='sdk use java epp-oracle'
alias   java9='sdk use java 9-oracle'
alias  java10='sdk use java 10-oracle'
alias  java11='sdk use java 11-oracle'
alias  java12='sdk use java 12-oracle'
alias  java13='sdk use java 13-oracle'
alias  java14='sdk use java 14-oracle'
alias  java15='sdk use java 15-oracle'
alias  java16='sdk use java 16-oracle'
alias  java17='sdk use java 17-oracle'
alias  java18='sdk use java 18-oracle'
alias  java19='sdk use java 19-oracle'
alias  java20='sdk use java 20-oracle'
alias  java21='sdk use java 21-oracle'
alias  java22='sdk use java 22-oracle'
alias  java23='sdk use java 23-oracle'
alias graal17="sdk use java 17-graal"
alias graal21="sdk use java 21-graal"
alias graal22="sdk use java 22-graal"
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
mkdir -p '/tmp/zlib'
tar --extract --file '/tmp/zlib-1.3.1.tar.gz' --directory '/tmp/zlib' --strip-components 1

(cd '/tmp/zlib';
./configure --prefix='/usr/lib/musl' --static;
make;
make install;)

for GRAALVM_PATH in '/usr/lib/jvm/graalvm-17' '/usr/lib/jvm/graalvm-21' '/usr/lib/jvm/graalvm-22'
do
  mkdir -p "${GRAALVM_PATH}/lib/static/linux-amd64/musl"
  cp '/tmp/zlib/libz.a' "${GRAALVM_PATH}/lib/static/linux-amd64/musl"
done

rm -rf '/tmp/zlib'
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Create the working directory
# ------------------------------------------------------------------------------
sudo -i -u opc bash << 'EOF'
mkdir -p '/home/opc/workspace'
EOF
# ------------------------------------------------------------------------------
