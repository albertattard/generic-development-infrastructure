#!/bin/bash

set -e

# ------------------------------------------------------------------------------
# Upgrade the system to the current release (takes several minutes to run)
# Note that the updates will vary depending on when this command executes
# ------------------------------------------------------------------------------
# dnf upgrade -y
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Verify all uploaded binaries
# ------------------------------------------------------------------------------
sha256sum --check '/tmp/checksums.txt'
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
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install Kotlin
# ------------------------------------------------------------------------------
rm -rf '/usr/lib/kotlin/'
mkdir -p '/usr/lib/kotlin/'
unzip '/tmp/kotlin-compiler.zip' -d '/usr/lib/kotlin/'
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install the dependencies required to build the statically linked native image
# ------------------------------------------------------------------------------
dnf config-manager --set-enabled ol9_codeready_builder
dnf install -y git-all gcc glibc-devel zlib-devel libstdc++-static make
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install hey, an HTTP load generator and ApacheBench (ab) replacement
# ------------------------------------------------------------------------------
mkdir -p '/usr/local/sbin'
curl \
  --location \
  --silent \
  --output '/usr/local/sbin/hey' \
  'https://hey-release.s3.us-east-2.amazonaws.com/hey_linux_amd64'
chmod +x '/usr/local/sbin/hey'
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install the Docker Engine to build container for the native image. Based on
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
# Install dive (https://github.com/wagoodman/dive) to explore a docker image
# layers.  Based on
#  - https://github.com/wagoodman/dive?tab=readme-ov-file#installation
# ------------------------------------------------------------------------------
DIVE_VERSION=$(curl -sL "https://api.github.com/repos/wagoodman/dive/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
curl \
  --location \
  --silent \
  --output "/tmp/dive_${DIVE_VERSION}_linux_amd64.rpm" \
  "https://github.com/wagoodman/dive/releases/download/v${DIVE_VERSION}/dive_${DIVE_VERSION}_linux_amd64.rpm"
dnf install -y "/tmp/dive_${DIVE_VERSION}_linux_amd64.rpm"
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install the Markdown Executor (me)
# ------------------------------------------------------------------------------
sudo -i -u opc bash << 'EOF'
mkdir -p '/home/opc/.local/bin'
curl \
  --silent \
  --location\
  --output '/home/opc/.local/bin/me' \
  'https://github.com/albertattard/me/releases/latest/download/me'
chmod +x '/home/opc/.local/bin/me'
EOF
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Setup Maven Toolchains
# ------------------------------------------------------------------------------
sudo -i -u opc bash << 'EOF'
mkdir -p '/home/opc/.m2'
cp -f '/tmp/toolchains.xml' '/home/opc/.m2/toolchains.xml'
EOF
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install SDKMAN
# ------------------------------------------------------------------------------
sudo -i -u opc bash << 'EOF'
curl -s 'https://get.sdkman.io' | bash
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
# Install MUSL required to build the static native image.
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
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Install zlib (https://zlib.net), a compression library that will be complied
# and included into the GraalVM musl GCC toolchain.
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
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Create the working directory
# ------------------------------------------------------------------------------
sudo -i -u opc bash << 'EOF'
mkdir -p '/home/opc/workspace'
EOF
# ------------------------------------------------------------------------------
