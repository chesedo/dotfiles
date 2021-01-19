#!/bin/sh

# Install
sudo apt install -y zsh
chsh -s $(which zsh)
ln -sf $PWD/.zshrc ~/.zshrc
rm -rf ~/.oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc

# Setups
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Install powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
ln -sf $PWD/.p10k.zsh ~/.p10k.zsh

# Z install (update)
wget -O ~/z.sh https://raw.githubusercontent.com/rupa/z/master/z.sh
