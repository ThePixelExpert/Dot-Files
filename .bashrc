# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'
export PATH="$HOME/.local/npm-global/bin:$PATH"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"

export ANTHROPIC_API_KEY="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"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
