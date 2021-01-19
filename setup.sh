#!/bin/sh

sudo apt update

# Install fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# Install zsh
./setup-zsh.sh
