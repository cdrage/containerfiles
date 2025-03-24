#!/bin/bash
set -euox pipefail

kver=$(cd /usr/lib/modules && echo *)

cat >/tmp/fake-uname <<EOF
#!/usr/bin/env bash

if [ "\$1" == "-r" ] ; then
  echo ${kver}
  exit 0
fi

exec /usr/bin/uname \$@
EOF
install -Dm0755 /tmp/fake-uname /tmp/bin/uname

PATH=/tmp/bin:$PATH dkms autoinstall -k ${kver}
PATH=/tmp/bin:$PATH akmods --force --kernels ${kver}