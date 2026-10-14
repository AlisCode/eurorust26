#!/usr/bin/env nix-shell
#! nix-shell -i sh -p ssh-chat

set -eu

cd -- "$(dirname -- "$0")"

exec ssh-chat --identity=ssh-chat.key --bind=0.0.0.0:2022 --whitelist=whitelist.txt --log=logs.txt "$@"
