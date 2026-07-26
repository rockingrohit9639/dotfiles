# ─────────────────────────────────────────────────────────────
#  zshrc — portable across macOS (arm/intel) and Linux
# ─────────────────────────────────────────────────────────────

unset KITTY_SHELL_INTEGRATION

# 🧰 Helper: prepend to PATH only if the directory exists and isn't already there
path_prepend() {
  [[ -d "$1" ]] || return 0
  case ":$PATH:" in
    *":$1:"*) ;;
    *) export PATH="$1:$PATH" ;;
  esac
}

# 🍺 Homebrew — must come first so everything below can find brew-installed tools
for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  if [[ -x "$_brew" ]]; then
    eval "$("$_brew" shellenv)"
    break
  fi
done
unset _brew

# 📂 PATH
path_prepend "$HOME/.local/bin"
path_prepend "$HOME/.sst/bin"                        # sst
path_prepend "$HOME/.fly/bin"                        # Fly.io
export FLYCTL_INSTALL="$HOME/.fly"

export BUN_INSTALL="$HOME/.bun"                      # bun
path_prepend "$BUN_INSTALL/bin"

export PNPM_HOME="$HOME/.local/share/pnpm"           # pnpm
path_prepend "$PNPM_HOME"

# ─────────────────────────────────────────────────────────────
#  Oh My Zsh
# ─────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=""                    # prompt comes from starship, below
ZSH_DISABLE_COMPFIX="true"      # skip the group-writable warning on brew dirs
DISABLE_MAGIC_FUNCTIONS="true"  # much faster pasting of long/URL-ish text

zstyle ':omz:update' mode reminder

# Completion functions shipped by brew formulae (_bat, _fd, _rg, _gh, _eza, …).
# Has to land in FPATH *before* Oh My Zsh runs compinit.
if [[ -n "$HOMEBREW_PREFIX" && -d "$HOMEBREW_PREFIX/share/zsh/site-functions" ]]; then
  FPATH="$HOMEBREW_PREFIX/share/zsh/site-functions:$FPATH"
fi

# 🧩 Plugins
#   fzf-tab must load after compinit but before any plugin that wraps widgets,
#   and fast-syntax-highlighting must be last. Oh My Zsh sources these in order.
plugins=(
  git
  gh
  sudo                      # press ESC twice to prefix the last command with sudo
  zoxide
  fzf-tab                   # fuzzy, previewable Tab menu
  zsh-autosuggestions       # ghost-text suggestions from history
  fast-syntax-highlighting  # keep last
)

source "$ZSH/oh-my-zsh.sh"

# ─────────────────────────────────────────────────────────────
#  Completion behaviour (must come after compinit)
# ─────────────────────────────────────────────────────────────
autoload -Uz compinit bashcompinit && bashcompinit

setopt AUTO_MENU            # show the completion menu on a second Tab
setopt COMPLETE_IN_WORD     # complete from the cursor, not just end of word
setopt ALWAYS_TO_END        # move cursor to end after completing
setopt AUTO_CD              # `foo/` cds into foo
setopt AUTO_PARAM_SLASH     # add a trailing / when completing a directory
unsetopt MENU_COMPLETE      # don't auto-insert the first match
unsetopt FLOW_CONTROL       # free up ctrl-s / ctrl-q

# case-insensitive, then partial-word, then substring matching
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z-_}={A-Za-z_-}' \
  'r:|=*' \
  'l:|=* r:|=*'
zstyle ':completion:*' menu no                    # fzf-tab replaces the menu
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:warnings' format '%F{red}no matches%f'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"
zstyle ':completion:*' special-dirs true           # offer ./ and ../
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

# ── fzf-tab ──────────────────────────────────────────────────
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' fzf-flags --height=60% --layout=reverse --border
zstyle ':fzf-tab:*' use-fzf-default-opts yes
# preview directory contents when completing cd / ls / paths
if (( $+commands[eza] )); then
  zstyle ':fzf-tab:complete:*:*' fzf-preview \
    '[[ -d $realpath ]] && eza -1 --color=always --icons=always $realpath'
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons=always $realpath'
fi
# preview env vars and git refs
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
  fzf-preview 'echo ${(P)word}'
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'

# ── per-tool completions ─────────────────────────────────────
# fzf: Ctrl-R history, Ctrl-T files, Alt-C cd, plus ** trigger completion
if (( $+commands[fzf] )); then
  if fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)
    # fzf's integration rebinds Tab to its own fzf-completion, clobbering
    # fzf-tab. Hand Tab back — fzf-completion stays as fzf-tab's fallback,
    # and ** trigger completion keeps working either way.
    (( $+functions[enable-fzf-tab] )) && enable-fzf-tab
  fi
  export FZF_DEFAULT_OPTS='--height=50% --layout=reverse --border --info=inline'
  if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  fi
  (( $+commands[bat] )) && export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {}'"
fi

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# bun
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# Generated completions, cached so we only shell out to each tool once
_zsh_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
[[ -d $_zsh_cache ]] || mkdir -p "$_zsh_cache"

_load_completion() {  # _load_completion <name> <command to generate it...>
  local f="$_zsh_cache/$1.zsh"
  if [[ ! -s $f ]]; then
    shift
    "$@" >| "$f" 2>/dev/null || { rm -f "$f"; return 1; }
  fi
  [[ -s $f ]] && source "$f"
}

(( $+commands[pnpm] ))   && _load_completion pnpm   pnpm completion zsh
(( $+commands[docker] )) && _load_completion docker docker completion zsh
(( $+commands[kubectl] )) && _load_completion kubectl kubectl completion zsh
(( $+commands[rustup] )) && _load_completion rustup rustup completions zsh
(( $+commands[npm] ))    && _load_completion npm    npm completion

# ─────────────────────────────────────────────────────────────
#  History
# ─────────────────────────────────────────────────────────────
[[ -z "$HISTFILE" ]] && HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=$HISTSIZE

setopt EXTENDED_HISTORY        # record timestamps
setopt INC_APPEND_HISTORY      # write as you go, not just on exit
setopt SHARE_HISTORY           # share between running shells
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE       # leading space keeps a command out of history
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY             # expand !! and let you confirm before running

# ─────────────────────────────────────────────────────────────
#  Prompt & tool init
# ─────────────────────────────────────────────────────────────
(( $+commands[starship] )) && eval "$(starship init zsh)"
(( $+commands[thefuck] ))  && eval "$(thefuck --alias)"

# ─────────────────────────────────────────────────────────────
#  Aliases
# ─────────────────────────────────────────────────────────────
(( $+commands[bat] )) && alias cat='bat'
(( $+commands[nvim] )) && { alias vi='nvim'; alias vim='nvim'; export EDITOR='nvim'; }
(( $+commands[eza] )) && {
  alias ls='eza --color=always --long --git --icons=always --no-time --no-user'
  alias lt='eza --tree --level=2 --color=always --icons=always'
  alias la='eza --color=always --long --git --icons=always --all'
}
(( $+commands[lazygit] )) && alias lg='lazygit'
(( $+commands[kitty] )) && alias ssh='kitty +kitten ssh'

alias zshconfig='${EDITOR:-vi} ~/.zshrc'
alias src='source ~/.zshrc'
# alias cd=z

# ─────────────────────────────────────────────────────────────
#  Functions
# ─────────────────────────────────────────────────────────────
# 📂 Yazi — quit with `q` to stay put, `Q` to cd into the last directory
function yy() {
  local tmp cwd
  tmp="$(mktemp -t yazi-cwd.XXXXXX)" || return 1
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
    builtin cd -- "$cwd" || return
  fi
  command rm -f -- "$tmp"
}

# zellij auto-start (opt in by uncommenting)
# (( $+commands[zellij] )) && eval "$(zellij setup --generate-auto-start zsh)"

# Machine-specific overrides, kept out of git
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
