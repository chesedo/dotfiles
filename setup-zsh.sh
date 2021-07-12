#!/bin/sh

# Install
ln -sf $PWD/.zshrc ~/.zshrc
rm -rf ~/.oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc

ZSH_CUSTOM=$ZSH/custom

# Setups
if [ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  echo "zsh-autosuggestions already exists"
else
  git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
fi

if [ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  echo "zsh-syntax-highlighting already exists"
else
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
fi

# Install powerlevel10k
if [ -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  echo "powerlevel10k already exists"
else
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
fi

ln -sf $PWD/.p10k.zsh ~/.p10k.zsh
ln -sf $PWD/.containerized-aliases.zsh ~/.containerized-aliases.zsh

# # Instal fzf
# git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
# ~/.fzf/install --all
