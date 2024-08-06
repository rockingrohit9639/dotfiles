# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="alanpeabody"

# Plugins
plugins=(git zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting zsh-autocomplete gh zoxide sudo)

source $ZSH/oh-my-zsh.sh

# Aliases
alias cat=bat
alias cd=z
alias zshconfig="vi ~/.zshrc"
alias ls="eza --color=always --long --git --icons=always --no-time --no-user"
alias ssh="kitty +kitten ssh"
alias src="source ~/.zshrc"

# nvim
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# The F*ck
eval $(thefuck --alias)

# Yazi
function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

