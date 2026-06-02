#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
projects_dir="${PROJECTS_DIR:-$HOME/Projects}"

mkdir -p "$projects_dir" "$HOME/Library/Inbox" "$HOME/Library/Documents" \
    "$HOME/Media/Images" "$HOME/Media/Videos" "$HOME/Media/Music"

ln -sfn Projects/Unitree_Go2 "$HOME/Unitree_Go2"
ln -sfn Projects/IsaacLab "$HOME/IsaacLab"
ln -sfn Projects/Unitree_Go2/training/isaac_lab/unitree_rl_lab "$HOME/unitree_rl_lab"

if [ -d "$projects_dir/IsaacLab/omx_f_isaaclab" ]; then
    ln -sfn IsaacLab/omx_f_isaaclab "$projects_dir/omx_f_isaaclab"
fi

env_line='[ -f "$HOME/Projects/Unitree_Go2/scripts/workspace_env.sh" ] && . "$HOME/Projects/Unitree_Go2/scripts/workspace_env.sh"'
if ! grep -Fq "$env_line" "$HOME/.bashrc" 2>/dev/null; then
    {
        printf '\n# Unitree Go2 workspace environment\n'
        printf '%s\n' "$env_line"
    } >> "$HOME/.bashrc"
fi

if command -v xdg-user-dirs-update >/dev/null 2>&1; then
    xdg-user-dirs-update --set DOWNLOAD "$HOME/Library/Inbox" || true
    xdg-user-dirs-update --set DOCUMENTS "$HOME/Library/Documents" || true
    xdg-user-dirs-update --set PICTURES "$HOME/Media/Images" || true
    xdg-user-dirs-update --set VIDEOS "$HOME/Media/Videos" || true
    xdg-user-dirs-update --set MUSIC "$HOME/Media/Music" || true
fi

printf 'Workspace environment installed from %s\n' "$repo_root"
printf 'Run: source ~/.bashrc\n'
