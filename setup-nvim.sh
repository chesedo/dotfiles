#!/bin/sh

# Setup plugins and config
git clone --depth 1 https://github.com/wbthomason/packer.nvim \
	 ~/.local/share/nvim/site/pack/packer/start/packer.nvim

mkdir -p ~/.config
ln -sf $PWD/nvim ~/.config/nvim

# Install plugins
nvim --headless +PackerInstall +qa
