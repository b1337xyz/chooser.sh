#!/usr/bin/env bash

set -xeo pipefail

bash chooser.sh {1..22}
seq 1 30 | bash chooser.sh -
x=$(bash chooser.sh $(ls -a))
echo "$x"
find ~/ -type d | head -1000 | bash chooser.sh -
