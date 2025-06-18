#!/usr/bin/env bash
set -x
export CAROOT="$(pwd)"

mkcert -key-file internal-key.pem -cert-file internal.pem \
    'home.internal' \
    'torrent.internal' \
    'git.internal' \
    'localhost' '127.0.0.1' '::1'
