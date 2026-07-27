#!/usr/bin/env bash
#
# Sync VSCodium config and extensions between this repo and the machine.
#
#   ./sync.sh export   capture this machine's VSCodium state into the repo
#   ./sync.sh import   apply the repo's state to this machine
#
# settings.json, keybindings.json and snippets/ are symlinked by `import`, so
# edits made inside the editor land straight in the repo and show up in `git
# status`. Extensions can't be symlinked, so they live in extensions.txt and are
# replayed with `codium --install-extension`.
#
# VSCodium keeps its user config in a different place on each OS, which is why
# this is a script rather than a stow package like the rest of the repo.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Files symlinked into the VSCodium user directory
LINKED_FILES=(settings.json keybindings.json)
LINKED_DIRS=(snippets)

log()  { printf '\033[1;34m==>\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m warn\033[0m %s\n' "$1"; }
die()  { printf '\033[1;31mError:\033[0m %s\n' "$1" >&2; exit 1; }

user_dir() {
  case "$(uname -s)" in
    Darwin) printf '%s\n' "$HOME/Library/Application Support/VSCodium/User" ;;
    Linux)  printf '%s\n' "${XDG_CONFIG_HOME:-$HOME/.config}/VSCodium/User" ;;
    *)      die "Unsupported OS: $(uname -s)" ;;
  esac
}

require_codium() {
  command -v codium >/dev/null 2>&1 \
    || die "codium not on PATH. Install VSCodium, then enable its shell command."
}

# Already pointing at the copy in this repo?
linked_here() {
  local path="$1" want="$2"
  [[ -L "$path" && "$(readlink "$path")" == "$want" ]]
}

link_into_place() {
  local src="$1" dest="$2"
  if linked_here "$dest" "$src"; then
    log "already linked: $(basename "$dest")"
    return 0
  fi
  # Back up anything real that would block the symlink
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    warn "backing up $dest -> $dest.pre-dotfiles.bak"
    mv "$dest" "$dest.pre-dotfiles.bak"
  fi
  rm -f "$dest"
  ln -s "$src" "$dest"
  log "linked $(basename "$dest")"
}

cmd_export() {
  require_codium
  local dir
  dir="$(user_dir)"
  [[ -d "$dir" ]] || die "No VSCodium user directory at $dir"

  local f
  for f in "${LINKED_FILES[@]}"; do
    if linked_here "$dir/$f" "$REPO/$f"; then
      log "$f is a symlink into the repo, nothing to copy"
    elif [[ -f "$dir/$f" ]]; then
      cp "$dir/$f" "$REPO/$f"
      log "copied $f"
    fi
  done

  local d
  for d in "${LINKED_DIRS[@]}"; do
    if linked_here "$dir/$d" "$REPO/$d"; then
      log "$d/ is a symlink into the repo, nothing to copy"
    elif [[ -d "$dir/$d" ]]; then
      mkdir -p "$REPO/$d"
      rsync -a --delete "$dir/$d/" "$REPO/$d/"
      log "copied $d/"
    fi
  done

  # Keep the header comment, replace the extension list below it
  local tmp
  tmp="$(mktemp)"
  grep '^#' "$REPO/extensions.txt" > "$tmp" 2>/dev/null || true
  codium --list-extensions | sort >> "$tmp"
  mv "$tmp" "$REPO/extensions.txt"
  log "wrote $(grep -cv '^#' "$REPO/extensions.txt" || true) extensions to extensions.txt"
}

cmd_import() {
  require_codium
  local dir
  dir="$(user_dir)"
  mkdir -p "$dir"

  local f
  for f in "${LINKED_FILES[@]}"; do
    [[ -f "$REPO/$f" ]] && link_into_place "$REPO/$f" "$dir/$f"
  done

  local d
  for d in "${LINKED_DIRS[@]}"; do
    [[ -d "$REPO/$d" ]] && link_into_place "$REPO/$d" "$dir/$d"
  done

  local installed ext
  installed="$(codium --list-extensions)"
  while IFS= read -r ext; do
    [[ -z "$ext" || "$ext" == \#* ]] && continue
    if grep -qxFi "$ext" <<<"$installed"; then
      log "extension already installed: $ext"
    else
      log "installing extension: $ext"
      codium --install-extension "$ext" --force \
        || warn "failed to install $ext"
    fi
  done < "$REPO/extensions.txt"
}

main() {
  case "${1:-}" in
    export) cmd_export ;;
    import) cmd_import ;;
    *) die "usage: $(basename "$0") {export|import}" ;;
  esac
}

main "$@"
