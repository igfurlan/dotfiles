# Set up the prompt
setopt histignorealldups sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit
source <(kubectl completion zsh)

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

### Aliases
alias lt="eza --tree --level=2 --long --icons --git"
alias ll="ls -lh"
alias la="eza -lah"
alias fzfp='fzf -m --preview "batcat --style numbers --color always {}"'
alias cat="batcat --paging never --style plain"
alias k="kubectl"

### Load starship
eval "$(starship init zsh)"

### Environment variables
export KUBECONFIG=/home/igfurlan/.kube/config
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

### Load zsh plugins
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /home/igfurlan/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /home/linuxbrew/.linuxbrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh

### To use substring search with up/down arrows
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down

### Load fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
