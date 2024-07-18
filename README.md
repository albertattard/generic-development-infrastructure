# Generic Development Infrastructure

Creates a generic Java **development** environment on the cloud that includes
all versions of Oracle Java, Oracle GraalVM and more.

This repository is intended to be used within other repositories, such as
workshops that require an instance on OCI. Run the following command from within
an existing repository to include the `infrastructure` directory.

```shell
$ git submodule add \
  --name 'infrastructure' \
  'https://github.com/albertattard/generic-development-infrastructure' \
  './infrastructure'
```

For more information, please refer to the
[git submodule documentation](https://git-scm.com/book/en/v2/Git-Tools-Submodules).

## Run Wrapper

You can add run wrappers that allows you to run commands remotely without having
to ssh to the remove OCI instance.

File: `runw`

```bash
#!/bin/bash

set -e

# Get the IP address of the OCI instance where the code will be synced and
# command executed
IP_ADDRESS=$(terraform -chdir='../../infrastructure/oci/terraform' output -json | jq --raw-output '.instance_public_ip.value')

# The place where the code is placed
WORKSPACE='/home/opc/workspace'

# Sync the files from the parent directory before executing any commands. We
# need the files from the parent directory as there are the parent POM and the
# Maven wrapper.
rsync \
  --rsh 'ssh -i ~/.ssh/ssh-key-oci-instance.key' \
  --recursive \
  --update \
  --delete \
  --exclude '.DS_Store' \
  --exclude '.gradle' \
  --exclude '.idea' \
  --exclude 'build' \
  --exclude 'generated' \
  --exclude 'target' \
  --exclude '.git*' \
  --exclude 'mvnw.cmd' \
  --exclude 'runw' \
  --exclude 'scpw' \
  .. \
  "opc@${IP_ADDRESS}:${WORKSPACE}"

# Switch to GraalVM 21
SWITCH_JAVA='sdk use java 21-graal'

# The current project/directory
PROJECT="${PWD##*/}"

# The remote directory from where the commands are executed
WORKDIR="${WORKSPACE}/${PROJECT}"

# Build the command
COMMAND=("${SWITCH_JAVA};cd ${WORKDIR};$@")

# Execute the given command(s)
ssh -i ~/.ssh/ssh-key-oci-instance.key "opc@${IP_ADDRESS}" "${COMMAND[@]}"
```

This bash script syncs the files to make sure that files are copied to the
remote instance before executing any command. Then it executes the command
remotely.

You can run commands locally and have these executed remotely.

```shell
$ ./runw ls -la
```

The output is printed in the local terminal. Note that any generated files are
not automatically copied locally.

## Feedback

Please send any feedback to: `albertattard@gmail.com`.
