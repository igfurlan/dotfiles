# DOTFILES

Você pode enviar os arquivos para onde quiser usando o parâmetro --target. Exemplo:
> $ stow -t /home/igfurlan/.config/ starship

Com o comando acima, o conteudo da pasta starship vai para o path especificado como target.

Estrutura da pasta ~/.config/

![image](https://github.com/user-attachments/assets/84b041e4-0726-4b06-9105-89b48d051a71)

---

## Install FZF

Clone the git repo 
> git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
Then install it by running the below
> ~/.fzf/install


---
### ZSH Plugins

Head to https://github.com/zsh-users and there you will find the instructions for installation of each plugin that you want. 
In the zsh/ folder of this repository you will find configuration already in place of .zshrc file for zsh-syntax-highlighting, zsh-history-substring-search and zsh-autosuggestions

---
### Install tools

First install brew package manager using the brew folder of this repo.
Running the file scripts/ubuntu-tools-setup.sh will install some tools like eza, batcat and starship for you.
