# ~/.zshenv — read first, for every zsh invocation.
#
# OSC leak fix (earliest layer): when attaching tmux over SSH, tmux probes the
# terminal background (OSC 11) and the reply can arrive during shell startup and
# get echoed onto the screen as  ^[]11;rgb:..../..../....^[\ . Disable echo as
# early as possible for interactive shells inside tmux; the line editor echoes
# typing on its own, and ~/.zshrc drains the stray reply and restores echo for
# commands. Guarded so scripts / non-tmux shells are never affected.
if [[ -o interactive && -n $TMUX ]]; then
  stty -echo 2>/dev/null
fi
