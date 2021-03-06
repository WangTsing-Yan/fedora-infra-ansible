#!/bin/sh

# used as root
# root gpg keychain should have PUBLIC key with `user name` copr-keygen-backup-key
# (per https://pagure.io/fedora-infrastructure/issue/8904)

PATH_TO_KEYRING_DIR="/var/lib/copr-keygen"
BACKUP_DIR=/backup
OUTPUT_FILE="$BACKUP_DIR/copr_keygen_keyring_$(date -I).tar.gz.gpg"

tar --exclude="*agent*" -czPf - "$PATH_TO_KEYRING_DIR" \
    | gpg2 --output "$OUTPUT_FILE".tmp --encrypt \
           --recipient copr-keygen-backup-key --always-trust \
&& mv "$OUTPUT_FILE.tmp" "$OUTPUT_FILE"

# shell pattern matching provides sorted output
previous=
for file in "$BACKUP_DIR"/*; do
    test -z "$previous" || rm "$previous"
    previous=$file
done
