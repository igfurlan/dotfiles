sudo apt update

# GNU stow
sudo apt -y install stow && sudo apt install curl -y && sudo apt install yq -y

# brew package manager
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo >> /home/igfurlan/.bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/igfurlan/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
sudo apt-get install build-essential
brew install gcc

# nushell
brew install nushell
sudo cp /home/linuxbrew/.linuxbrew/bin/nu /usr/local/bin/nu

# bat
sudo apt install bat
mkdir -p ~/.local/bin
ln -s /usr/bin/batcat ~/.local/bin/bat

# eza
brew install eza

# fzf
brew install fzf

# https://github.com/tonsky/FiraCode/wiki/Installing
brew install font-fira-code

# neovim
brew install neovim

# starship
curl -sS https://starship.rs/install.sh | sh

# devbox
curl -fsSL https://get.jetify.com/devbox | bash

