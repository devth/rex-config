#!/bin/bash
set -euo pipefail

client=${1:?Usage: scripts/setup-rex.sh REX_APP_CLIENT_ID (find it with rex client ls)}
root=$(cd "$(dirname "$0")/.." && pwd)
rex_bin=${REX_BIN:-rex}
command -v "$rex_bin" >/dev/null || { printf 'Rex CLI not found. Set REX_BIN to its path.\n' >&2; exit 1; }
backup_dir="$HOME/.local/state/rex-config"
umask 077
mkdir -p "$backup_dir"
backup=$(mktemp "$backup_dir/preferences-$(date +%Y%m%d-%H%M%S)-XXXXXX")
defaults export com.superlogical.rex "$backup"
printf 'Private preference backup: %s\n' "$backup"

# Import via Rex's supported API; never modify the app bundle.
"$rex_bin" -C "$client" do client.appearance.switch_mode mode=light
"$rex_bin" -C "$client" do client.theme.import "path=$root/themes/Solarized Light"
"$rex_bin" -C "$client" do client.appearance.switch_mode mode=dark
"$rex_bin" -C "$client" do client.theme.import "path=$root/themes/Solarized Dark"

mode=light
if [[ $(defaults read -g AppleInterfaceStyle 2>/dev/null || true) == Dark ]]; then
    mode=dark
fi
"$rex_bin" -C "$client" do client.appearance.switch_mode "mode=$mode"

# Only portable appearance preferences; no sessions, routes, or server settings.
defaults write com.superlogical.rex Workspace.terminalFontName -string 'MesloLGS Nerd Font Mono'
defaults write com.superlogical.rex Workspace.terminalFontPointSize -float 14
defaults write com.superlogical.rex Workspace.terminalCellHeightPercent -float 1.0
defaults write com.superlogical.rex Workspace.terminalFontSmoothing -bool false
defaults write com.superlogical.rex Workspace.paneDensity -string compact
defaults write com.superlogical.rex Workspace.inactivePaneFadeMode -string both
defaults write com.superlogical.rex Workspace.usesStandardInactiveWindowPaneStyles -bool true
defaults write com.superlogical.rex Workspace.preservesWindowWidthOnSidebarToggle -bool true
defaults write com.superlogical.rex Workspace.sidebarPosition -string left
defaults write com.superlogical.rex Workspace.sidebarShowsActivity -bool false
defaults write com.superlogical.rex Workspace.tabIconTintMode -string off
defaults write com.superlogical.rex Workspace.tabStyle -string vertical

printf '\nSelect Auto in Rex Settings > Interface > Color Scheme.\n'
printf 'Quit and reopen Rex to load stored preferences. If it overwrites them on exit, rerun only the defaults write lines while Rex is closed.\n'
printf 'Remote Control can be disabled after import unless you need it for other tools.\n'
