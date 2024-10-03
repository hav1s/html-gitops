#!/bin/bash

BASE_DIR=$(SELF=$(dirname "$0") && bash -c "cd \"$SELF\" && pwd")

find "$BASE_DIR" -type f -name "secret.encrypted.yaml" -exec sh -c '
    for file do
        # Decrypt the file and write the output to a new file, replacing .encrypted.yaml with .yaml
        sops -d "$file" > "${file%.encrypted.yaml}.decrypted.yaml"
        echo "Decrypted: $file to ${file%.encrypted.yaml}.decrypted.yaml"
    done
' sh {} +

echo "Decryption complete!"
