# 🛠️ Dotfiles

My personal terminal setup — **zsh + starship + tmux + Neovim**, plus a handful
of modern CLI tools and Kubernetes helpers. Built and tested on **Fedora**, but
easily adapted to other distros (swap `dnf` for your package manager).

The configs live in this repo and are linked into place with **GNU Stow**, so the
files you edit stay here in git and your home directory just points at them.

![terminal preview](https://github.com/user-attachments/assets/84b041e4-0726-4b06-9105-89b48d051a71)

---

## 📦 What's inside

| Folder      | What it configures        | Gets linked to                     |
|-------------|---------------------------|------------------------------------|
| `zsh/`      | `.zshrc`, `.zshenv`, `.vimrc` | `~/.zshrc`, `~/.zshenv`, `~/.vimrc` |
| `tmux/`     | `.tmux.conf`              | `~/.tmux.conf`                     |
| `starship/` | `starship.toml` (prompt)  | `~/.config/starship/starship.toml` |
| `bat/`      | `config` (better `cat`)   | `~/.config/bat/config`             |
| `nvim/`     | Neovim IDE config         | `~/.config/nvim/`                  |
| `k9s/`      | k9s config + resource aliases | `~/.config/k9s/`               |
| `btop/`     | btop system monitor       | `~/.config/btop/`                  |
| `nushell/`  | Nushell config (optional) | `~/.config/nushell/`               |
| `scripts/`  | `setup-system.sh` helper  | _(run directly, not linked)_       |

---

## 🚀 First-time install

> **New here?** Run these steps in order, top to bottom. Each block is safe to
> copy/paste as-is. Steps 1–7 install software; step 8 links the configs.

### 1. Clone this repo

```bash
git clone https://github.com/igfurlan/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. zsh, and make it your login shell

```bash
sudo dnf install -y zsh
chsh -s "$(which zsh)"
```

Log out and back in for the shell change to take effect.

### 3. A Nerd Font

The prompt, `eza` icons and Neovim all use glyphs that only exist in a patched
"Nerd Font". Without one you'll see boxes (□) everywhere.

```bash
mkdir -p ~/.local/share/fonts && cd ~/.local/share/fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/FiraCode.zip
unzip FiraCode.zip && rm FiraCode.zip
fc-cache -fv
cd ~/dotfiles
```

Then set **FiraCode Nerd Font** as the font in your terminal emulator's settings.
This is a GUI setting — the install alone won't switch it.

### 4. Homebrew + Kubernetes tools (helper script)

Installs Homebrew (needed for two zsh plugins) and, optionally, `kubectl`, `k9s`,
`kubectx`, `stern`, `popeye` and `helm`. It's interactive and asks before each
step. Its prompts are in Portuguese; `s`/`y` = yes, `n` = no.

```bash
./scripts/setup-system.sh
```

### 5. Core CLI tools

```bash
# starship — the prompt
curl -sS https://starship.rs/install.sh | sh

# fzf — fuzzy finder (Ctrl-R history, Ctrl-T files)
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# bat — cat with syntax highlighting
sudo dnf install -y bat

# eza — modern ls (used by the ll/la/lt aliases)
mkdir -p ~/.local/bin && cd /tmp
wget https://github.com/eza-community/eza/releases/download/v0.23.4/eza_x86_64-unknown-linux-gnu.zip
unzip -o eza_x86_64-unknown-linux-gnu.zip && rm eza_x86_64-unknown-linux-gnu.zip
mv eza ~/.local/bin/eza && cd ~/dotfiles

# stow — creates the symlinks in step 8
brew install stow
```

### 6. zsh plugins

The paths below are hardcoded in `.zshrc`, so clone to exactly these locations:

```bash
# syntax highlighting — must live in $HOME
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/zsh-syntax-highlighting

# autosuggestions + history-substring-search — via Homebrew
brew install zsh-autosuggestions zsh-history-substring-search
```

If you skip this step nothing breaks — `.zshrc` checks each plugin exists before
loading it — you just lose those features.

### 7. tmux, Neovim, and the vim colorscheme

```bash
sudo dnf install -y tmux neovim

# gruvbox for plain `vim` (the vi alias). Without it, vim prints
# "E185: Cannot find color scheme 'gruvbox'" on every launch.
mkdir -p ~/.vim/pack/plugins/start
git clone --depth 1 https://github.com/morhetz/gruvbox.git ~/.vim/pack/plugins/start/gruvbox
```

tmux's plugin manager (tpm) installs itself on first launch — `.tmux.conf`
bootstraps it, so there's nothing to clone by hand.

### 8. Link everything with Stow

Stow needs each target directory to exist first, then it creates the symlinks:

```bash
cd ~/dotfiles
mkdir -p ~/.config/{starship,bat,nvim,k9s,btop,nushell}

stow -t ~                  zsh        # ~/.zshrc, ~/.zshenv, ~/.vimrc
stow -t ~                  tmux       # ~/.tmux.conf
stow -t ~/.config/starship starship
stow -t ~/.config/bat      bat
stow -t ~/.config/nvim     nvim
stow -t ~/.config/k9s      k9s
stow -t ~/.config/btop     btop
stow -t ~/.config/nushell  nushell    # optional — only if you use nushell
```

> **Note:** k9s and btop rewrite their own config files at runtime (on exit, or
> when you change a setting in the UI). Because those files are symlinks into
> this repo, those writes land in git — so `git status` will occasionally show
> changes you didn't make by hand. That's expected; commit or discard as you like.

> ⚠️ **"existing target is not owned by stow"?** A real file is in the way. Move
> it aside and re-run:
> ```bash
> mv ~/.zshrc ~/.zshrc.backup
> stow -t ~ zsh
> ```

### 9. Open a new terminal 🎉

Run `exec zsh`, or just open a new window. On first launch:

- **tmux** auto-installs its plugins. If the status bar looks plain, press
  `Ctrl-b` then `I` (capital i) to install them manually.
- **Neovim** auto-installs its plugins via lazy.nvim, then compiles treesitter
  parsers. The first `nvim` takes 30–60 seconds; after that it's instant.

---

## 📝 Neovim

A hand-rolled IDE config (not a distro like LazyVim), managed by **lazy.nvim**.

### Layout

```
nvim/
├── init.lua                  # leader key, then loads the two config files
├── lua/config/
│   ├── lazy.lua              # bootstraps lazy.nvim + the plugin list
│   └── settings.lua          # editor options and general keymaps
└── after/plugin/             # one file per plugin, loaded after plugins are ready
    ├── cmp.lua      lsp.lua       telescope.lua   treesitter.lua
    ├── harpoon.lua  undotree.lua  rust.lua        python.lua      go.lua
```

**Leader is `Space`.**

### Keymaps

| Key | Does |
|-----|------|
| `<leader>ff` / `<leader>fg` | Telescope: find files / git files |
| `<leader>ps` | Telescope: grep for a string |
| `<leader>a` / `Ctrl-e` | Harpoon: mark file / open menu |
| `Ctrl-h` `Ctrl-t` `Ctrl-n` `Ctrl-s` | Harpoon: jump to marked file 1–4 |
| `<leader>u` | Toggle undotree |
| `gd` / `K` / `<leader>vrn` | LSP: definition / hover / rename |
| `<leader>vca` / `<leader>vrr` | LSP: code action / references |
| `[d` / `]d` | Previous / next diagnostic |
| `Ctrl-Space` / `Ctrl-y` | Completion: trigger / confirm |
| `<leader><leader>term` | Open a terminal split |

### Language servers

None are installed by default, so startup never blocks on a download. Open
Neovim and run `:Mason`, then install what you need. A good first one:

```vim
:MasonInstall lua-language-server
```

Anything you install through Mason is enabled automatically on next launch.

### Per-language setup

Neovim's side is already configured — these install the **toolchains** it drives.

**Python**
```bash
sudo dnf install -y python3 python3-pip
```
Then `:MasonInstall pyright`. In a `.py` buffer: `<leader><leader>py` opens a
REPL split, `\d` sends the current line (or visual selection), `\aa` sends
everything up to the cursor.

**Go**
```bash
sudo dnf install -y go
```
Then `:MasonInstall gopls` and, once inside Neovim, `:GoInstallBinaries` to fetch
`gofumpt`, `goimports` and friends. Keymaps: `<leader>gr` run, `<leader>gt` test,
`<leader>gc` coverage, `<leader>gi` fix imports. Files are formatted on save.

**Rust**
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
. "$HOME/.cargo/env"
rustup component add rust-analyzer
sudo dnf install -y gdb          # for debugging
```
Do **not** install `rust_analyzer` through Mason — rustaceanvim manages its own
copy, and two clients on one buffer means duplicate diagnostics. Keymaps:
`<leader>rr` run, `<leader>ca` code action, `<leader>K` hover actions,
`<leader>e` explain error, `<leader>db` toggle breakpoint, `<leader>dc` continue.

### What is deliberately NOT in this repo

**This repo is public.** These stay out of it, and should stay out:

| File | Why |
|------|-----|
| `~/.gitconfig` | Local identity + credential wiring; see below |
| `~/.config/gh/hosts.yml` | GitHub CLI OAuth token |
| `~/.kube/config` | Cluster credentials |
| `~/.fzf.zsh`, `~/.fzf.bash` | Generated by fzf's installer, and pin a versioned path |

**Git credentials go through `gh`, not a plaintext file.** Set it up once per
machine with:

```bash
gh auth login          # if not already authenticated
gh auth setup-git      # makes git ask gh for the token
```

That writes a `credential."https://github.com".helper` entry pointing at
`gh auth git-credential`, so git asks gh for a token on demand instead of
reading one from disk. Do **not** use `credential.helper = store` — it saves
the token in cleartext in `~/.git-credentials`, readable by any process
running as you.

---

## 🔄 Day-to-day usage

Everything is symlinked, so **edit the files in `~/dotfiles`** and changes apply
immediately:

```bash
cd ~/dotfiles
nvim zsh/.zshrc                                  # edit
exec zsh                                         # reload
git add -A && git commit -m "tweak zsh config"   # save
git push
```

Adding a **new** file to an already-stowed package needs a re-stow so the link
picks it up:

```bash
stow -R -t ~/.config/nvim nvim
```

To **unlink** a package: `stow -D -t <target> <package>`.

---

## 🧩 Aliases & helpers (from `zsh/.zshrc`)

| Alias | Does |
|-------|------|
| `ll` / `la` / `lt` | `eza` variants — long, long+hidden, tree |
| `cat` | `bat` (syntax-highlighted, no pager) |
| `k` | `kubectl`, with completion |
| `vi` | `vim` |
| `fzfp` | fuzzy file picker with a `bat` preview |
| `kdebug` | pipe any output to Claude for SRE analysis |
| `ktriage` | recent cluster events → Claude triage |
| `ksecure` / `ktune` | cluster security audit / perf review via Claude |
| `restic-snaphost` / `restic-snapk8s` | list restic snapshots (host / k8s repo) |
| `restic-checkhost` / `restic-checkk8s` | verify those repos |

---

## 🩹 Troubleshooting

- **Icons show as boxes (□)** — your terminal isn't set to a Nerd Font. Revisit
  step 3; installing the font isn't enough, you must select it in the terminal's
  settings.
- **tmux prefix** — `Ctrl-b` (default) or `Ctrl-a` (added as a second prefix).
- **tmux plugins not working** — the very last line of `.tmux.conf` must be
  `run '#{TMUX_PLUGIN_MANAGER_PATH}/tpm/tpm'`. Without it tpm downloads the
  plugins but never loads them. Reload with `Ctrl-b` then `r`, or `tmux kill-server`.
- **Stray `]11;rgb:...` on the prompt in tmux over SSH** — tmux probes the
  terminal's background colour on attach and the reply can land on the prompt.
  `.zshenv` and `.zshrc` contain a three-part guard (marked `OSC leak fix`) that
  suppresses and cleans it up.
- **`Del` inserts `~` instead of deleting** — fixed in `.zshrc` via
  `bindkey '^[[3~' delete-char`.
- **Neovim: can't paste with the middle mouse button** — Neovim ≥ 0.8 defaults to
  `mouse=nvi`, which means *Neovim* handles mouse events instead of the terminal,
  disabling terminal drag-select and middle-click paste. `y`/`p` use the system
  clipboard (`clipboard=unnamedplus`), or uncomment `vim.opt.mouse = ""` in
  `nvim/lua/config/settings.lua` to give the mouse back to the terminal.
- **Neovim clipboard doesn't work** — install a provider:
  `sudo dnf install -y wl-clipboard` (Wayland) or `xsel` (X11). Check with
  `:checkhealth vim.provider`.
- **Nushell** — the config here is kept for future use; nushell itself isn't
  part of the install steps. `sudo dnf install -y nushell`, then stow the package.
