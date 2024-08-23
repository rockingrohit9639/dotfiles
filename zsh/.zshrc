unset KITTY_SHELL_INTEGRATION

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="alanpeabody"

# 🧩 Plugins
plugins=(git zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting zsh-autocomplete gh zoxide sudo)

source $ZSH/oh-my-zsh.sh

# 🔀 Aliases
alias cat=bat
alias cd=z
alias zshconfig="vi ~/.zshrc"
alias ls="eza --color=always --long --git --icons=always --no-time --no-user"
alias ssh="kitty +kitten ssh"
alias src="source ~/.zshrc"

# 📝 nvim
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# 📜 Set history file path and size
if [[ -z "$HISTFILE" ]]; then
    HISTFILE="$HOME/.zsh_history"
fi
HISTSIZE=100000
SAVEHIST=$HISTSIZE

# 🌸 Initialize prompt
eval "$(starship init zsh)"

# 🍺 Homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# The F*ck
eval $(thefuck --alias)

# 📂 Yazi
function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}


# sst
export PATH=/home/rohit/.sst/bin:$PATH

# pnpm
export PNPM_HOME="/home/rohit/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
