#!/usr/bin/env bash
#
# install.sh — symlink this repo's commands, skills, and agents into ~/.claude/
#
#   ./install.sh            install (idempotent; re-run after a git pull)
#   ./install.sh --check    report what is linked, missing, or blocked; write nothing
#   ./install.sh --remove   remove only the symlinks this script created
#
# Safety rule: the script only ever creates, replaces, or deletes a symlink whose
# target resolves inside this repo. A real file or directory at a destination path
# is reported as BLOCKED and left completely alone — which is what keeps the
# pre-existing ~/.claude/skills/llm-wiki safe.

set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
CLAUDE_DIR="${CLAUDE_HOME:-$HOME/.claude}"

MODE="install"
case "${1:-}" in
  ""|install)      MODE="install" ;;
  --check|-c)      MODE="check" ;;
  --remove|-r)     MODE="remove" ;;
  --help|-h)       sed -n '2,16p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
  *) echo "install.sh: unknown argument '$1' (try --help)" >&2; exit 2 ;;
esac

n_linked=0    # destination is our symlink, pointing at the right place
n_missing=0   # nothing there yet
n_blocked=0   # a real file, or a symlink pointing somewhere else
n_changed=0   # created / repaired / removed this run

# is_ours <path> — true when <path> is a symlink resolving inside REPO_DIR
is_ours() {
  [ -L "$1" ] || return 1
  local resolved
  resolved="$(readlink -f "$1" 2>/dev/null)" || return 1
  case "$resolved" in "$REPO_DIR"/*) return 0 ;; *) return 1 ;; esac
}

# handle <source> <destination>
handle() {
  local src="$1" dest="$2" rel="${2#$CLAUDE_DIR/}"

  if is_ours "$dest" && [ "$(readlink -f "$dest")" = "$(readlink -f "$src")" ]; then
    case "$MODE" in
      install|check) n_linked=$((n_linked + 1)); [ "$MODE" = check ] && printf '  linked   ~/.claude/%s\n' "$rel" ;;
      remove)        rm -f "$dest"; n_changed=$((n_changed + 1)); printf '  removed  ~/.claude/%s\n' "$rel" ;;
    esac
    return
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    # Something is there. Only touch it if it is one of ours (a stale link).
    if is_ours "$dest"; then
      case "$MODE" in
        install) rm -f "$dest"; ln -s "$src" "$dest"; n_linked=$((n_linked + 1)); n_changed=$((n_changed + 1))
                 printf '  repaired ~/.claude/%s\n' "$rel" ;;
        check)   n_blocked=$((n_blocked + 1)); printf '  STALE    ~/.claude/%s -> %s\n' "$rel" "$(readlink "$dest")" ;;
        remove)  rm -f "$dest"; n_changed=$((n_changed + 1)); printf '  removed  ~/.claude/%s (stale)\n' "$rel" ;;
      esac
    else
      n_blocked=$((n_blocked + 1))
      printf '  BLOCKED  ~/.claude/%s (not ours — left untouched)\n' "$rel"
    fi
    return
  fi

  case "$MODE" in
    install) ln -s "$src" "$dest"; n_linked=$((n_linked + 1)); n_changed=$((n_changed + 1))
             printf '  linked   ~/.claude/%s\n' "$rel" ;;
    check)   n_missing=$((n_missing + 1)); printf '  missing  ~/.claude/%s\n' "$rel" ;;
    remove)  : ;;
  esac
}

# Parent directories: created on install, never removed (they may hold other things).
if [ "$MODE" = install ]; then
  for d in commands skills agents; do
    [ -d "$CLAUDE_DIR/$d" ] || { mkdir -p "$CLAUDE_DIR/$d"; printf '  created  ~/.claude/%s/\n' "$d"; }
  done
fi

printf '%s: %s\n' "$(basename "${BASH_SOURCE[0]}")" "$MODE ($REPO_DIR -> $CLAUDE_DIR)"

for src in "$REPO_DIR"/commands/*.md; do
  [ -e "$src" ] || continue
  handle "$src" "$CLAUDE_DIR/commands/$(basename "$src")"
done

for src in "$REPO_DIR"/skills/*/; do
  [ -d "$src" ] || continue
  src="${src%/}"
  handle "$src" "$CLAUDE_DIR/skills/$(basename "$src")"
done

for src in "$REPO_DIR"/agents/*.md; do
  [ -e "$src" ] || continue
  handle "$src" "$CLAUDE_DIR/agents/$(basename "$src")"
done

echo
case "$MODE" in
  install) printf 'installed: %d linked, %d blocked, %d changed this run\n' "$n_linked" "$n_blocked" "$n_changed" ;;
  check)   printf 'check: %d linked, %d missing, %d blocked\n' "$n_linked" "$n_missing" "$n_blocked"
           [ "$n_missing" -eq 0 ] && [ "$n_blocked" -eq 0 ] || exit 1 ;;
  remove)  printf 'removed: %d symlinks (real files and other skills untouched)\n' "$n_changed" ;;
esac
