#!/bin/sh

# Install
sudo apt install -y neovim

# Setup plugins and config
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
ln -sf /home/pieter/git/dotfiles/nvim .config/nvim

# Install plugins
nvim --headless +PlugInstall +qa