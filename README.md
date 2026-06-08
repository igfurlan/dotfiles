# 🛠️ Dotfiles

My personal terminal setup — **zsh + starship + tmux**, plus a handful of modern
CLI tools and Kubernetes helpers. Built and tested on **Fedora**, but easily
adapted to other distros (swap `dnf` for your package manager).

The configs live in this repo and are linked into place with **GNU Stow**, so the
files you edit stay here in git and your home directory just points at them.

![terminal preview](https://github.com/user-attachments/assets/84b041e4-0726-4b06-9105-89b48d051a71)

---

## 📦 What's inside

| Folder      | What it configures         | Gets linked to                       |
|-------------|----------------------------|--------------------------------------|
| `zsh/`      | `.zshrc`, `.vimrc`         | `~/.zshrc`, `~/.vimrc`               |
| `tmux/`     | `.tmux.conf`              | `~/.tmux.conf`                       |
| `starship/` | `starship.toml` (prompt)  | `~/.config/starship/starship.toml`   |
| `bat/`      | `config` (better `cat`)   | `~/.config/bat/config`               |
| `nvim/`     | Neovim config             | `~/.config/nvim/`                    |
| `nushell/`  | Nushell config            | `~/.config/nushell/`                 |
| `scripts/`  | `setup-system.sh` helper  | _(run directly, not linked)_         |

### Tools this setup uses

| Tool                             | What it is                                    | Install with        |
|----------------------------------|-----------------------------------------------|---------------------|
| **zsh**                          | The shell itself                              | `dnf`               |
| **FiraCode Nerd Font**           | Font with icons/glyphs (the prompt needs it)  | manual download     |
| **starship**                     | The prompt                                    | official installer  |
| **tmux**                         | Terminal multiplexer                          | `dnf`               |
| **tpm**                          | tmux plugin manager                           | `git clone`         |
| **fzf**                          | Fuzzy finder (Ctrl-R, Ctrl-T)                 | `git clone`         |
| **bat**                          | `cat` with syntax highlighting                | `dnf`               |
| **eza**                          | Modern `ls` (used by `ll`, `la`, `lt`)        | download binary     |
| **Homebrew**                     | Package manager for the plugins/k8s tools     | `setup-system.sh`   |
| **zsh-syntax-highlighting**      | Colors your command line                      | `git clone`         |
| **zsh-autosuggestions**          | Greys-out history suggestions                 | `brew`              |
| **zsh-history-substring-search** | Up/Down search history by substring           | `brew`              |
| **kubectl + k8s tools**          | kubectl, k9s, kubectx, stern, popeye, helm    | `setup-system.sh`   |

---

## 🚀 Fresh install (step by step)

> 💡 **New here? Just run the steps in order, top to bottom.** Copy/paste each
> block into your terminal. Lines starting with `#` are comments — you can ignore them.

### 1. Clone this repo

```bash
git clone https://github.com/<your-user>/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Install zsh and make it your default shell

```bash
sudo dnf install -y zsh
chsh -s "$(which zsh)"      # log out and back in afterwards for this to take effect
```

### 3. Install the FiraCode Nerd Font

The prompt and the `eza`/`bat` icons need a Nerd Font, or you'll see boxes (□) instead of icons.

```bash
mkdir -p ~/.local/share/fonts && cd ~/.local/share/fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/FiraCode.zip
unzip FiraCode.zip && rm FiraCode.zip
fc-cache -fv
cd ~/dotfiles
```

Then set **FiraCode Nerd Font** as the font in your terminal emulator's settings.

### 4. Install Homebrew + Kubernetes tools (helper script)

This installs Homebrew (used for some plugins) and optionally the k8s tools.
It's interactive — it asks before each step.

```bash
./scripts/setup-system.sh
```

### 5. Install the core CLI tools

```bash
# starship (prompt)
curl -sS https://starship.rs/install.sh | sh

# fzf (fuzzy finder) — installs key bindings into ~/.fzf.zsh
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# bat (better cat)
sudo dnf install -y bat
mkdir -p ~/.local/bin
ln -sf "$(command -v bat || command -v batcat)" ~/.local/bin/bat

# eza (better ls)
wget https://github.com/eza-community/eza/releases/download/v0.23.4/eza_x86_64-unknown-linux-gnu.zip
unzip eza_x86_64-unknown-linux-gnu.zip && rm eza_x86_64-unknown-linux-gnu.zip
mv eza ~/.local/bin/eza
```

### 6. Install the zsh plugins

```bash
# syntax highlighting (cloned into your HOME, to match .zshrc)
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/zsh-syntax-highlighting

# autosuggestions + history-substring-search (via Homebrew)
brew install zsh-autosuggestions zsh-history-substring-search
```

### 7. Install tmux + its plugin manager (tpm)

```bash
sudo dnf install -y tmux
git clone https://github.com/tmux-plugins/tpm ~/.local/share/tmux/plugins/tpm
```

### 8. Link the dotfiles with Stow

Stow creates the symlinks from your home directory into this repo. Run these
from inside `~/dotfiles`:

```bash
brew install stow          # if you don't have it yet

cd ~/dotfiles
stow -t ~                  zsh        # ~/.zshrc, ~/.vimrc
stow -t ~                  tmux       # ~/.tmux.conf
stow -t ~/.config/starship starship   # ~/.config/starship/starship.toml
stow -t ~/.config/bat      bat        # ~/.config/bat/config
stow -t ~/.config/nvim     nvim       # optional: Neovim
stow -t ~/.config/nushell  nushell    # optional: Nushell
```

> ⚠️ **Conflict error?** If Stow says a file "already exists", a real file is in
> the way. Back it up and remove it, then re-run:
> ```bash
> mv ~/.zshrc ~/.zshrc.backup
> stow -t ~ zsh
> ```

### 9. Open a new terminal 🎉

Start a new shell (or run `exec zsh`). On first launch tmux auto-installs its
plugins; if it doesn't, open tmux and press **`Ctrl-b` then `I`** (capital i).

---

## 🔄 Day-to-day usage

Because everything is symlinked, **edit the files right here in `~/dotfiles`** and
the changes apply immediately (the files in `~` point back here):

```bash
cd ~/dotfiles
vim zsh/.zshrc          # edit
exec zsh                # reload the shell
git add -A && git commit -m "tweak zsh config"   # save to git
```

To link a **new** config later, drop it in a package folder and `stow` that folder.
To **unlink** a package: `stow -D -t <target> <package>`.

---

## 🧩 Handy aliases & helpers (defined in `zsh/.zshrc`)

| Alias / function | Does                                              |
|------------------|---------------------------------------------------|
| `ll`, `la`, `lt` | `ls` variants via **eza** (long, all, tree)       |
| `cat`            | **bat** (syntax-highlighted, no pager)            |
| `k`              | `kubectl` (with full completion)                  |
| `vi`             | `vim`                                             |
| `fzfp`           | fuzzy file picker with a bat preview              |
| `kdebug`         | pipe any output to Claude for SRE analysis        |
| `ktriage`        | recent cluster events → Claude triage             |
| `restic-*`       | restic snapshot/check shortcuts                   |

---

## 🩹 Notes / troubleshooting

- **tmux prefix key:** `Ctrl-b` (default) or `Ctrl-a` (added as a second prefix).
- **Stray `]11;rgb:...` characters in tmux over SSH:** tmux probes the terminal's
  background color on attach; over SSH the reply can arrive late and land on the
  prompt. `.zshrc` includes a guard (top and bottom, marked `OSC leak fix`) that
  suppresses and cleans it up.
- **`Del` key inserting `~` instead of deleting:** fixed in `.zshrc` with
  `bindkey '^[[3~' delete-char`.
- **Icons show as boxes (□):** your terminal isn't using a Nerd Font — revisit step 3.
