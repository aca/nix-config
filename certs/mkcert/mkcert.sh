#!/usr/bin/env bash
set -x
export CAROOT="$(pwd)"

unset JAVA_HOME

mkcert -key-file internal-key.pem -cert-file internal.pem \
    '*.internal' \
    'home.internal' \
    'log.internal' \
    'vm.internal' \
    'grafana.internal' \
    'torrent.internal' \
    'git.internal' \
    'localhost' '127.0.0.1' '::1'
