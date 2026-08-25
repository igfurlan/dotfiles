# env.nu — loaded before config.nu on every nushell start.
#
# Installed by:
# version = "0.101.0"

$env.config.buffer_editor = "vi"

# PATH
use std "path add"

# Homebrew, only if it is actually installed.
if ("/home/linuxbrew/.linuxbrew/bin" | path exists) {
    path add "/home/linuxbrew/.linuxbrew/bin"
}

path add ($nu.home-path | path join ".local/bin")

# Starship prompt
mkdir ~/.cache/starship
starship init nu | save -f ~/.cache/starship/init.nu

# Was hardcoded to /home/igfurlan/... (the GitHub username, not the local user),
# so it pointed at a non-existent path on this machine.
$env.STARSHIP_CONFIG = ($nu.home-path | path join ".config/starship/starship.toml")
