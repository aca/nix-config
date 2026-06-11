#!/usr/bin/env bash
cd ~/.config/qbt

if realpath .qbt.toml | grep -q "seedbox.toml"; then
    ln -sf seedbox-impx.toml .qbt.toml
    exit 0
fi

ln -sf seedbox.toml .qbt.toml


