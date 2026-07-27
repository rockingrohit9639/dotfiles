#!/usr/bin/env bash
#
# Bootstrap this dotfiles repo on a fresh machine.
# Works on macOS (Homebrew) and Debian/Ubuntu Linux (apt + Homebrew).
# Safe to re-run: every step checks before it acts.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"

# Stow packages in this repo, each mapping into $HOME
STOW_PACKAGES=(git kitty nvim starship zsh)

# Tools installed via Homebrew on both platforms, so versions stay in step
BREW_PACKAGES=(
  bat            # cat with syntax highlighting
  eza            # modern ls
  fd             # fast find
  fzf            # fuzzy finder, drives fzf-tab and Ctrl-R
  gh             # GitHub CLI
  go             # toolchain for gopls
  lazygit        # git TUI
  neovim
  ripgrep        # rg, powers telescope live_grep
  rsync
  starship       # prompt
  stow           # symlink manager for this repo
  thefuck        # command corrector
  tmux
  tree-sitter-cli # nvim-treesitter (main branch) compiles parsers with this
  yazi           # file manager
  zoxide         # smarter cd
  # yazi's optional previewers
  ffmpeg
  imagemagick
  poppler
  resvg
  sevenzip
)

# Oh My Zsh custom plugins: "repo-url name"
ZSH_PLUGINS=(
  "https://github.com/zsh-users/zsh-autosuggestions zsh-autosuggestions"
  "https://github.com/zdharma-continuum/fast-syntax-highlighting fast-syntax-highlighting"
  "https://github.com/Aloxaf/fzf-tab fzf-tab"
)

log()  { printf '\033[1;34m==>\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m warn\033[0m %s\n' "$1"; }
die()  { printf '\033[1;31mError:\033[0m %s\n' "$1" >&2; exit 1; }

have() { command -v "$1" >/dev/null 2>&1; }

# ─── Homebrew ────────────────────────────────────────────────
setup_homebrew() {
  local candidate
  for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
    if [[ -x "$candidate" ]]; then
      eval "$("$candidate" shellenv)"
      log "Homebrew found at $candidate"
      return 0
    fi
  done

  log "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
    [[ -x "$candidate" ]] && { eval "$("$candidate" shellenv)"; return 0; }
  done
  die "Homebrew installed but the brew binary could not be located."
}

# ─── System packages ─────────────────────────────────────────
install_system_packages() {
  case "$OS" in
    Linux)
      log "Updating apt and installing build prerequisites..."
      sudo apt-get update -qq
      # Needed to compile Homebrew formulae and treesitter parsers
      sudo apt-get install -y --no-install-recommends \
        build-essential curl file git procps unzip zsh
      ;;
    Darwin)
      if ! xcode-select -p >/dev/null 2>&1; then
        log "Installing Xcode Command Line Tools (needed to compile treesitter parsers)..."
        xcode-select --install || warn "Finish the Xcode CLT installer, then re-run this script."
      fi
      ;;
  esac
}

install_brew_packages() {
  log "Installing CLI tools via Homebrew..."
  # brew install is already idempotent and much faster in one invocation
  brew install "${BREW_PACKAGES[@]}"

  if ! have bun; then
    log "Installing bun..."
    brew install oven-sh/bun/bun
  fi
}

# ─── Fonts ───────────────────────────────────────────────────
install_fonts() {
  # kitty.conf asks for "MonaspiceKr Nerd Font"
  case "$OS" in
    Darwin)
      if ls "$HOME/Library/Fonts" 2>/dev/null | grep -qi monaspice; then
        log "Monaspace Nerd Font already installed."
      else
        log "Installing Monaspace Nerd Font..."
        brew install --cask font-monaspace-nerd-font
      fi
      ;;
    Linux)
      local dir="$HOME/.local/share/fonts"
      if ls "$dir" 2>/dev/null | grep -qi monaspice; then
        log "Monaspace Nerd Font already installed."
        return 0
      fi
      log "Installing Monaspace Nerd Font..."
      mkdir -p "$dir"
      local tmp
      tmp="$(mktemp -d)"
      curl -fsSL -o "$tmp/Monaspace.zip" \
        https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Monaspace.zip
      unzip -qo "$tmp/Monaspace.zip" -d "$dir"
      rm -rf "$tmp"
      have fc-cache && fc-cache -f >/dev/null
      ;;
  esac
}

# ─── Node ────────────────────────────────────────────────────
install_node() {
  export NVM_DIR="$HOME/.nvm"
  if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    log "Installing nvm..."
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
  else
    log "nvm already installed."
  fi

  # shellcheck disable=SC1091
  source "$NVM_DIR/nvm.sh"
  if ! nvm which node >/dev/null 2>&1; then
    log "Installing the latest LTS Node..."
    nvm install --lts
    nvm alias default 'lts/*'
  else
    log "Node already installed: $(node --version)"
  fi
}

# ─── Zsh ─────────────────────────────────────────────────────
install_oh_my_zsh() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    log "Oh My Zsh already installed."
  else
    log "Installing Oh My Zsh..."
    # --keep-zshrc so the installer never clobbers the .zshrc we stow below
    RUNZSH=no KEEP_ZSHRC=yes sh -c \
      "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
      "" --unattended --keep-zshrc
  fi
}

install_zsh_plugins() {
  local custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
  mkdir -p "$custom"
  local entry url name
  for entry in "${ZSH_PLUGINS[@]}"; do
    read -r url name <<<"$entry"
    if [[ -d "$custom/$name/.git" ]]; then
      log "zsh plugin $name already present."
    else
      log "Cloning zsh plugin $name..."
      git clone --depth=1 "$url" "$custom/$name"
    fi
  done
}

set_default_shell() {
  local zsh_path
  zsh_path="$(command -v zsh)"
  if [[ "${SHELL:-}" == "$zsh_path" ]]; then
    log "Zsh is already the default shell."
    return 0
  fi
  if ! grep -qxF "$zsh_path" /etc/shells; then
    log "Registering $zsh_path in /etc/shells..."
    echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
  fi
  log "Setting Zsh as the default shell..."
  chsh -s "$zsh_path" || warn "chsh failed; set the shell manually."
}

# ─── Symlinks ────────────────────────────────────────────────
stow_packages() {
  log "Linking config into \$HOME with stow..."
  local pkg
  for pkg in "${STOW_PACKAGES[@]}"; do
    [[ -d "$DOTFILES/$pkg" ]] || { warn "no such stow package: $pkg"; continue; }

    # Back up any real file that would block the symlink
    while IFS= read -r target; do
      local dest="$HOME/$target"
      if [[ -e "$dest" && ! -L "$dest" ]]; then
        warn "backing up existing $dest -> $dest.pre-dotfiles.bak"
        mv "$dest" "$dest.pre-dotfiles.bak"
      fi
    done < <(cd "$DOTFILES/$pkg" && find . -type f -o -type l | sed 's|^\./||')

    stow --dir="$DOTFILES" --target="$HOME" --restow "$pkg"
  done
}

# ─── Neovim ──────────────────────────────────────────────────
# Mason package names for the servers configured in nvim/lua/plugins/lsp.lua and
# the formatters in none-ls.lua. These are Mason's own names, which differ from
# the lspconfig names used in that file (e.g. lua_ls -> lua-language-server).
MASON_PACKAGES=(
  ast-grep
  astro-language-server
  bash-language-server
  biome
  css-lsp
  dockerfile-language-server
  gopls
  harper-ls
  html-lsp
  lua-language-server
  prisma-language-server
  sqlls
  tailwindcss-language-server
  typescript-language-server   # backs lspconfig.tsserver in lsp.lua
  # formatters / linters used by none-ls
  eslint_d
  prettier
  stylua
)

bootstrap_neovim() {
  log "Installing Neovim plugins (lazy.nvim)..."
  nvim --headless "+Lazy! sync" +qa 2>&1 | tail -5 || warn "Lazy sync reported problems."

  log "Installing LSP servers and formatters via Mason..."
  nvim --headless -c "MasonInstall ${MASON_PACKAGES[*]}" -c qa 2>&1 | tail -10 \
    || warn "Some Mason packages failed; check :Mason inside nvim."
}

# ─── VSCodium ────────────────────────────────────────────────
# Config lives at a different path per OS, so it is symlinked by
# vscodium/sync.sh rather than stowed. VSCodium itself is not installed here,
# same as kitty — install the app first and this picks it up.
bootstrap_vscodium() {
  if ! have codium; then
    warn "codium not on PATH; skipping VSCodium config. Run vscodium/sync.sh import later."
    return 0
  fi
  log "Linking VSCodium config and installing extensions..."
  "$DOTFILES/vscodium/sync.sh" import || warn "VSCodium sync reported problems."
}

main() {
  case "$OS" in
    Darwin|Linux) ;;
    *) die "Unsupported OS: $OS" ;;
  esac

  log "Bootstrapping dotfiles from $DOTFILES ($OS)"

  install_system_packages
  setup_homebrew
  install_brew_packages
  install_fonts
  install_node
  install_oh_my_zsh
  install_zsh_plugins
  stow_packages
  bootstrap_neovim
  bootstrap_vscodium
  set_default_shell

  log "Done. Open a new terminal, or run: exec zsh"
}

main "$@"
