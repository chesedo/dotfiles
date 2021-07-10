#!/bin/sh

sudo apt update

# Install

# # Install fzf
# git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
# ~/.fzf/install

# Install zsh
sudo apt install -y zsh fonts-powerline
chsh -s $(which zsh)
./setup-zsh.sh

# Install and setup nvim
sudo apt install -y neovim
./setup-nvim.sh
