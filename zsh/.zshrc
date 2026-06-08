# ============================================================================
# ~/.zshrc
# ============================================================================

# --- OSC leak fix (1/2) -----------------------------------------------------
# When attaching tmux over SSH, tmux probes the terminal background (OSC 11) and
# the reply can cross SSH late, landing on the prompt as ^[]11;rgb:..../..../..^[\.
# During shell startup the TTY echoes whatever arrives, so suppress echo now and
# flush/restore at the first prompt (part 2/2, at the bottom of this file).
if [[ -o interactive && -n $TMUX ]]; then
  stty -echo 2>/dev/null
fi

# --- History ----------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS   # drop older duplicate commands
setopt HIST_IGNORE_SPACE      # don't record commands starting with a space
setopt HIST_REDUCE_BLANKS     # tidy up whitespace before saving
setopt HIST_VERIFY            # expand !! etc. into the line instead of running it
setopt EXTENDED_HISTORY      # record timestamps
setopt SHARE_HISTORY         # share history live across sessions

# --- Keybindings ------------------------------------------------------------
# emacs keybindings even if EDITOR is vi
bindkey -e
bindkey -M emacs '^[[1;5D' backward-word    # ctrl-left
bindkey -M emacs '^[[1;5C' forward-word     # ctrl-right
bindkey '^[[3~' delete-char                  # Del: delete char under cursor (not insert ~)

# --- Completion -------------------------------------------------------------
autoload -Uz compinit
# Rebuild the completion dump at most once a day; otherwise load it cached (-C)
# for a faster startup. (Glob qualifiers only expand in array context, not in
# [[ ]], so the freshness test is done via an array.)
_zcompfresh=(${ZDOTDIR:-$HOME}/.zcompdump(Nmh-24))
if (( $#_zcompfresh )); then
  compinit -C        # dump is < 24h old: load cached, skip the security scan
else
  compinit           # missing or stale: full rebuild
fi
unset _zcompfresh

# kubectl completion is expensive to generate on every shell; cache it and only
# regenerate when the kubectl binary is newer than the cache.
if (( $+commands[kubectl] )); then
  _kube_cache=${XDG_CACHE_HOME:-$HOME/.cache}/zsh/kubectl_completion.zsh
  if [[ ! -s $_kube_cache || $commands[kubectl] -nt $_kube_cache ]]; then
    mkdir -p ${_kube_cache:h}
    kubectl completion zsh >| $_kube_cache
  fi
  source $_kube_cache
  compdef k=kubectl          # make the `k` alias use kubectl completion
  unset _kube_cache
fi

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

# --- Environment & PATH -----------------------------------------------------
# Homebrew first so $HOMEBREW_PREFIX is available below without re-invoking brew.
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
export STARSHIP_CONFIG=~/.config/starship/starship.toml
path=("$HOME/.local/bin" "$HOME/.npm-global/bin" $path)
export PATH
#export KUBECONFIG=/home/ifurlan/.kube/config

# --- Aliases ----------------------------------------------------------------
alias lt="eza --tree --level=2 --long --icons --git"
alias ll="ls -lh"
alias la="eza -lah"
alias fzfp='fzf -m --preview "bat --style numbers --color always {}"'
alias cat="bat --paging never --style plain"
alias k="kubectl"
alias vi="vim"

# --- Prompt -----------------------------------------------------------------
eval "$(starship init zsh)"

# --- Functions --------------------------------------------------------------
kdebug() {
  claude -p "You are a senior Kubernetes SRE. Analyze the following output, identify root causes, and propose concrete fixes:\n\n$(cat)"
}

ksecure() {
  kubectl get all -A -o yaml | claude -p "You are a Kubernetes security auditor. Identify misconfigurations, privilege risks, and hardening opportunities:"
}

ktune() {
  { kubectl top pods -A; kubectl top nodes; } | claude -p "You are a Kubernetes performance engineer. Identify bottlenecks and tuning opportunities:"
}

alias ktriage='kubectl get events -A --sort-by=".lastTimestamp" | tail -200 | kdebug'

# --- Restic -----------------------------------------------------------------
alias restic-snaphost="sudo bash -c 'source /etc/restic/env-host.sh && restic snapshots'"
alias restic-snapk8s="sudo bash -c 'source /etc/restic/env.sh && restic snapshots'"
alias restic-checkhost="sudo bash -c 'source /etc/restic/env-host.sh && restic check'"
alias restic-checkk8s="sudo bash -c 'source /etc/restic/env.sh && restic check'"

# ============================================================================
# ZLE widgets & plugins — ORDER MATTERS, keep these near the end.
#   1. integrations that define widgets (fzf, autosuggestions)
#   2. zsh-syntax-highlighting   (must be sourced last among highlighters)
#   3. zsh-history-substring-search (must be sourced AFTER syntax-highlighting)
# ============================================================================

# fzf key bindings & completion
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# autosuggestions
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# --- OSC leak fix (2/2) -----------------------------------------------------
# A ZLE widget that eats any OSC reply (ESC ]) that arrives while we're already
# at the prompt (e.g. re-attaching to an existing session) so it is never
# inserted or run. Defined before syntax-highlighting so it gets wrapped.
_zle_eat_osc() {
  local c
  while read -r -k 1 -t 0.1 c; do
    [[ $c == $'\a' || $c == '\' ]] && break   # BEL or the '\' of ST (ESC \)
  done
}
zle -N _zle_eat_osc
bindkey '\e]' _zle_eat_osc

# syntax highlighting (must be the last highlighter sourced)
source $HOME/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# history substring search (must come AFTER syntax-highlighting)
source $HOMEBREW_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh
export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='fg=default'
export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='fg=default'
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[OA' history-substring-search-up
bindkey '^[OB' history-substring-search-down
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down

# --- OSC leak fix (cleanup) --------------------------------------------------
# echo was disabled in ~/.zshenv. Keep it off through the FIRST prompt (the line
# editor echoes typing itself, so this is invisible) so a reply that lands right
# as the prompt appears is still swallowed. Drain the stray reply and wipe any
# residue on each early prompt, then restore echo once a command runs or by the
# second prompt — whichever comes first.
if [[ -o interactive && -n $TMUX ]]; then
  autoload -Uz add-zsh-hook
  typeset -gi _osc_prompts=0
  _osc_restore_echo() { stty echo 2>/dev/null }
  _osc_precmd() {
    local junk
    while read -r -k 1 -t 0.1 junk 2>/dev/null; do :; done   # drain leaked reply
    print -n $'\r\e[2K'                                       # wipe echoed residue
    (( _osc_prompts++ )) && { _osc_restore_echo; add-zsh-hook -d precmd _osc_precmd }
  }
  _osc_preexec() { _osc_restore_echo; add-zsh-hook -d preexec _osc_preexec; add-zsh-hook -d precmd _osc_precmd }
  add-zsh-hook precmd  _osc_precmd
  add-zsh-hook preexec _osc_preexec
fi
