# Dotfiles — GNU Stow helper.
#
#   make install   create the target dirs and link every package
#   make restow    re-link after adding/removing files inside a package
#   make unlink    remove all symlinks
#   make check     run the same syntax checks as CI

SHELL  := /bin/bash
STOW   ?= stow
CONFIG := $(HOME)/.config

HOME_PACKAGES   := zsh tmux
CONFIG_PACKAGES := starship bat nvim k9s btop nushell

.PHONY: help install restow unlink check

help:
	@echo "Targets:"
	@echo "  make install   create target dirs and stow every package"
	@echo "  make restow    re-link packages (after adding/removing files)"
	@echo "  make unlink    remove all symlinks"
	@echo "  make check     run local syntax checks"

install:
	mkdir -p $(CONFIG)/starship $(CONFIG)/bat $(CONFIG)/nvim \
	         $(CONFIG)/k9s $(CONFIG)/btop $(CONFIG)/nushell
	$(STOW) -t $(HOME) $(HOME_PACKAGES)
	$(STOW) -t $(CONFIG)/starship starship
	$(STOW) -t $(CONFIG)/bat bat
	$(STOW) -t $(CONFIG)/nvim nvim
	$(STOW) -t $(CONFIG)/k9s k9s
	$(STOW) -t $(CONFIG)/btop btop
	$(STOW) -t $(CONFIG)/nushell nushell

restow:
	$(STOW) -R -t $(HOME) $(HOME_PACKAGES)
	$(STOW) -R -t $(CONFIG)/starship starship
	$(STOW) -R -t $(CONFIG)/bat bat
	$(STOW) -R -t $(CONFIG)/nvim nvim
	$(STOW) -R -t $(CONFIG)/k9s k9s
	$(STOW) -R -t $(CONFIG)/btop btop
	$(STOW) -R -t $(CONFIG)/nushell nushell

unlink:
	$(STOW) -D -t $(HOME) $(HOME_PACKAGES)
	$(STOW) -D -t $(CONFIG)/starship starship
	$(STOW) -D -t $(CONFIG)/bat bat
	$(STOW) -D -t $(CONFIG)/nvim nvim
	$(STOW) -D -t $(CONFIG)/k9s k9s
	$(STOW) -D -t $(CONFIG)/btop btop
	$(STOW) -D -t $(CONFIG)/nushell nushell

check:
	bash -n scripts/setup-system.sh
	zsh -n zsh/.zshrc zsh/.zshenv
	@if command -v shellcheck >/dev/null; then shellcheck -S error scripts/setup-system.sh; else echo "shellcheck not installed, skipping"; fi
	@if command -v luac5.1 >/dev/null; then find nvim -name '*.lua' -print0 | xargs -0 -n1 luac5.1 -p; else echo "luac5.1 not installed, skipping"; fi
	@echo "syntax OK"
