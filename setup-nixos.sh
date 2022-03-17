#!/bin/sh

mkdir -p ~/.config/nixpks
ln -sf $PWD/home-manager/home.nix ~/.config/nixpkgs

sudo mkdir -p /etc/nixos
sudo ln -sf $PWD/nixos/configuration.nix /etc/nixos
