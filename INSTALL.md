# 1. Install zsh and make it default shell
sudo dnf install -y zsh
zsh --version
chsh -s $(which zsh)
grep $USER /etc/passwd


# 2. Install FiraCode font from NerdFonts
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/FiraCode.zip
unzip FiraCode.zip
rm FiraCode.zip
fc-cache -fv
fc-list | grep -i "fira"


# 3. Install starship theme 
curl -sS https://starship.rs/install.sh | sh


# 4. Install aditional packages
# 4.1 Fuzzy Finder (fzf)
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf 
~/.fzf/install

# 4.2 bat (cat on steroids)
sudo dnf install bat
mkdir -p ~/.local/bin
ln -s /usr/bin/bat ~/.local/bin/bat

# 4.3 eza (ls on steroids)
# https://github.com/eza-community/eza/blob/main/INSTALL.md
wget https://github.com/eza-community/eza/releases/download/v0.23.4/eza_x86_64-unknown-linux-gnu.zip
unzip eza_x86_64-unknown-linux-gnu.zip
rm eza_x86_64-unknown-linux-gnu.zip && mv eza ~/.local/bin/eza 


# 5. Install zsh plugins 
# 5.1 zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
echo "source ${(q-)PWD}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc

# 5.2 zsh-history-substring-search
brew install zsh-history-substring-search
echo 'source $(brew --prefix)/share/zsh-history-substring-search/zsh-history-substring-search.zsh' >> ~/.zshrc

# 5.3 zsh-autosuggestions
brew install zsh-autosuggestions
source '$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh' >> ~/.zshrc

