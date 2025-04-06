# env.nu
#
# Installed by:
# version = "0.101.0"
#

$env.config.buffer_editor = "vi"

# PATH
use std "path add"
path add /home/linuxbrew/.linuxbrew/bin/

mkdir ~/.cache/starship
starship init nu | save -f ~/.cache/starship/init.nu

$env.STARSHIP_CONFIG = "/home/igfurlan/.config/starship/starship.toml"
