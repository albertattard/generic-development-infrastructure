#!/bin/bash

set -e

IQN=$1
IPV4=$2
PORT=$3
DEVICE_PATH=$4
MOUNT_PATH=${5:-/home}

# Connect to the volume using iSCSI
iscsiadm -m node -o new -T "${IQN}" -p "${IPV4}:${PORT}"
iscsiadm -m node -o update -T "${IQN}" -n node.startup -v automatic
iscsiadm -m node -T "${IQN}" -p "${IPV4}:${PORT}" -l

# Sleep a bit as otherwise fdisk will not find the device path
sleep 10

# Create the partition using fdisk. Simulate user input (type 'n', press enter 4
# times and exit fdisk with a 'w') as the fdisk is expecting input
fdisk "${DEVICE_PATH}" <<EOF
n




w
EOF

# Sleep a bit as otherwise mkfs will not find the partition created by fdisk
sleep 10

# Format the partition (assuming that the device is '/dev/oracleoci/oraclevdb1')
# using mkfs. Simulate user input (type 'y', press enter once) as the mkfs is
# expecting input
PARTITION_PATH=${DEVICE_PATH}1
mkfs -t ext4 "${PARTITION_PATH}" <<EOF
y

EOF

# Copy the data to /tmp before mounting and the transfer this back, otherwise it
# will be lost.  Mounting the /home directory for example, without copying the
# files will prevent us to login as the ssh public key will be lost once
# mounted.
if test -d "${MOUNT_PATH}"; then
  cp -R "${MOUNT_PATH}" "/tmp/${MOUNT_PATH}"
fi

# Mount the partition
mkdir -p "${MOUNT_PATH}"
mount "${PARTITION_PATH}" "${MOUNT_PATH}"

# Automatically mount the volume on instance boot
cat <<EOF >> /etc/fstab

# Automatically mount the volume on instance boot
${PARTITION_PATH} ${MOUNT_PATH}    ext4   defaults,_netdev, nofail 0 2
EOF

# Copy the data back from /tmp after mounting to preserve the files
if test -d "/tmp/${MOUNT_PATH}"; then
  cp -R "/tmp/${MOUNT_PATH}" "${MOUNT_PATH}"
  rm -rf "/tmp/${MOUNT_PATH}"
fi
