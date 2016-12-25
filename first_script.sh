#!/bin/bash
PARENT_DIR="$(dirname `pwd`)"
cat <<EOF > ./nodes/solo.rb
cookbook_path "$PARENT_DIR"
EOF
