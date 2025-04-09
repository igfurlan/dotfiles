sudo apt update

# GNU stow
sudo apt install stow curl zsh yq btop net-tools -y

# bat
sudo apt install bat
mkdir -p ~/.local/bin
ln -s /usr/bin/batcat ~/.local/bin/bat

# eza & fzf
sudo apt install fzf eza -y

# starship
curl -sS https://starship.rs/install.sh | sh

# devbox
#curl -fsSL https://get.jetify.com/devbox | bash
