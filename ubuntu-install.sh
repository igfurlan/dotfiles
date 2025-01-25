sudo apt update

# GNU stow
sudo apt -y install stow

# brew package manager
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# nushell
brew install nushell

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
