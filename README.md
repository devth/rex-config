# Rex config

My portable [Rex](https://www.superlogical.com/rex) terminal setup: Solarized
Light/Dark, MesloLGS Nerd Font Mono, compact panes, vertical tabs, and a private
mobile-bridge configuration example.

This repo contains configuration only. It excludes credentials, pairing tokens,
Tailscale identities/hostnames, session history, window state, and full preference
exports. The bridge application remains in the separate **private**
[devth/rex-bridge](https://github.com/devth/rex-bridge) repo; access is required
for the optional bridge instructions below.

## Terminal setup

Requires macOS and Rex Beta. Install the font first, for example with Homebrew:

```sh
brew install --cask font-meslo-lg-nerd-font
git clone https://github.com/devth/rex-config.git
cd rex-config
```

Make Rex's bundled CLI available without modifying its app bundle:

```sh
export REX_BIN='/Applications/Rex Beta.app/Contents/Helpers/Rex Server.rex/Contents/MacOS/rex'
"$REX_BIN" client ls
```

Temporarily enable **Settings → Rex Server → Remote Control**, then run:

```sh
./scripts/setup-rex.sh APP_CLIENT_ID
```

The script backs up existing preferences privately under
`~/.local/state/rex-config/`, imports both themes using Rex's supported
`client.theme.import` API, and writes only the portable appearance preferences.
It does not alter your shell, Pi configuration, server settings, or sessions.
It finishes in the current macOS appearance rather than always leaving Dark on.

Afterward:

1. Select **Auto** in **Settings → Interface → Color Scheme**. The CLI exposes
   light/dark/toggle, not Auto; changing the preference externally does not reset
   a running app's forced mode.
2. Quit and reopen Rex to load the stored font/layout preferences. If Rex saves
   older values on exit, rerun the script's `defaults write` lines while it is
   closed; do not run the CLI theme-import steps while the app is closed.
3. Disable Remote Control again if no other tools need it.

Themes are Ghostty-format files using Ethan Schoonover's Solarized palette.
The setup does not install Fish, Starship, or other shell integrations.

### Undo

Select your previous themes and preferences in Rex Settings. A private full
preference backup is available at the path printed by the script, but importing
the whole backup also restores unrelated settings from that moment. Keep backups
out of Git and do not blindly import them over newer settings.

## Optional private mobile bridge

The bridge mirrors existing Pi processes in Rex. It does not start another
agent. Its implementation and operating details live in the private bridge repo.

Requirements: Node 22+, Rex Beta, and the standard Tailscale macOS app signed in
to your own tailnet. The Mac must remain awake and Rex/Pi must be running.

```sh
# Requires access to the private repository. Skip if already cloned.
gh repo clone devth/rex-bridge "$HOME/rex-bridge"
cd "$HOME/rex-bridge"
node scripts/install.mjs
node scripts/pair.mjs --copy
```

The installer generates a random pairing token if no config exists, derives the
HTTPS origin and exact owner identity from Tailscale, installs a per-user launch
agent, and enables **Tailscale Serve** on HTTPS port 443. It refuses to replace
another service's root proxy there. It can reuse an existing local config; it
does not rotate a pre-existing token.

`bridge/config.example.json` documents the shape, not a ready-to-run config.
**Do not copy its token or placeholders into a live service.** Let the installer
create `~/.config/rex-bridge/config.json` with local paths, identity, and secret.
The example's Rex app path may need updating if the app layout changes.

| Setting | Purpose |
| --- | --- |
| `port` | Loopback backend port, normally 4319 |
| `token` | Locally generated 256-bit pairing secret; never commit it |
| `origins` | Explicit local origins and your private Tailscale HTTPS origin |
| `rexBin` | App-bundled Rex CLI executable |
| `rexServer` | Local Unix socket URI for the current macOS user |
| `owner` | Exact Tailscale login allowed to access the HTTPS endpoint |

### Security and operation

- Node listens only on `127.0.0.1`; use private Serve, **never Funnel**.
- Remote access requires the configured Tailscale owner and pairing secret.
  Local access still requires pairing. Tailnet ACLs apply.
- The private pairing link grants terminal control with your account's
  privileges. Do not share it, log it, or put it in this repo.
- The local config should be mode `0600`. The app, secret, launch-agent plist,
  and logs stay outside this repo.
- Do not install another copy over a running bridge just to restore terminal
  appearance. Inspect the existing service/config first.
- Full pairing, token rotation, stop/remove, and limitations are documented in
  the bridge repo. No service or network settings change by cloning this repo.

## Local validation

```sh
bash -n scripts/setup-rex.sh
python3 -m json.tool bridge/config.example.json >/dev/null
```

Theme import and preference writes are intentionally manual, not part of
validation, because they change the running terminal.
