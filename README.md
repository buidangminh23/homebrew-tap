# buidangminh23/tap

Homebrew formulae and casks for tools published by [buidangminh23](https://github.com/buidangminh23).

| Type | Name | Tool |
|---|---|---|
| Formula | `codex-mcp-bridge` | [codex-mcp-bridge](https://github.com/buidangminh23/codex-mcp-bridge): two-way MCP bridge between Claude and Codex |
| Cask | `quota-control` | [Quota Control](https://github.com/buidangminh23/quota-control): Claude, Codex, Cursor and other AI coding limits in the menu bar, a Dynamic Island around the notch and a desktop widget |

## codex-mcp-bridge

### Install

```bash
brew install buidangminh23/tap/codex-mcp-bridge
```

This taps the repository and installs the bridge with Homebrew's `node`. The commands the npm
package ships land in Homebrew's `bin`: `codex-mcp-bridge`, `claude-mcp-bridge`, the
`*-install` registration commands, `bridge-projects`, `codex-full-access` and the rest. The one
exception is `codex-npm-footer-install`, which only reports `npm install -g` updates.

Register it with your clients the same way as the npm install, for example:

```bash
codex-mcp-bridge-install       # Claude Desktop
codex-bridge-code-install      # Claude Code
claude-mcp-bridge-install      # Codex
```

The installers record Homebrew's stable `opt` paths for the bridge and for Node.js, so the
registrations survive `brew upgrade`, and a running bridge reloads the new version on its own.
This needs codex-mcp-bridge 1.22.7 or later; re-run the installers once if you registered an
earlier version from Homebrew.

See the [bridge README](https://github.com/buidangminh23/codex-mcp-bridge#readme) for the full
setup.

If you also installed the bridge with `npm install -g`, keep one of the two. Whichever comes first
on your `PATH` wins, and `brew install` lists any command another install shadows.

### Upgrade and uninstall

```bash
brew upgrade codex-mcp-bridge
brew uninstall codex-mcp-bridge
```

Uninstalling removes the commands only. Client registrations and the bridge's state in `~/.codex`
stay until you remove them.

### How the formula follows releases

`.github/workflows/update-formulae.yml` runs every three hours and on demand. It reads the latest
version of `@minhspark/codex-mcp-bridge` from npm, checks the downloaded tarball against the
registry's SHA-512 integrity, writes the new URL and SHA-256, then installs, tests and audits the
formula on macOS before committing. A failed check leaves the formula where it was. To follow a
release at once:

```bash
gh workflow run update-formulae.yml -R buidangminh23/homebrew-tap
```

The same bump runs locally with `scripts/update-codex-mcp-bridge.sh`.

## Quota Control

### Install

```bash
brew install --cask buidangminh23/tap/quota-control
```

Quota Control needs an Apple Silicon Mac with macOS 14 (Sonoma) or later. Installing by the full
name, as above, also records Homebrew's trust for this cask, so later commands can use the short
name `quota-control`.

The app is signed ad hoc, not notarized by Apple. The cask clears the download's quarantine flag
after installing, so the app opens without the **Open Anyway** step in System Settings that a
browser download needs; the app registers its desktop widget the first time it opens. It also links
`usagectl` into Homebrew's `bin`, so the command works in any shell that has Homebrew on its
`PATH`.

Once installed, Quota Control updates itself from its GitHub releases, so `brew upgrade` leaves it
alone (`auto_updates true`). `brew upgrade --greedy` moves it to the version the cask names.

### Uninstall

```bash
brew uninstall --cask quota-control
```

This quits the app and removes it with its `usagectl` command. Accounts and settings stay in
`~/Library/Application Support/usage-control`; `brew uninstall --zap --cask quota-control` removes
them too, along with the launch agent older versions set up.

### How the cask follows releases

`.github/workflows/update-casks.yml` runs every three hours and on demand. It reads the latest
Quota Control release, takes the DMG's checksum from the release's `SHA256SUMS` and confirms it
against the downloaded DMG, then audits, installs and checks the cask on macOS before committing.
A release without a macOS DMG, or a failed check, leaves the cask where it was. To follow a
release at once, or to point the cask at a given tag:

```bash
gh workflow run update-casks.yml -R buidangminh23/homebrew-tap
gh workflow run update-casks.yml -R buidangminh23/homebrew-tap -f tag=v0.3.43
```

The same bump runs locally with `scripts/update-quota-control.sh [--tag vX.Y.Z]`, which needs an
authenticated `gh`. It never moves the cask to an older release unless you also pass
`--allow-downgrade`, which a dispatch with `-f tag=` does.

## Scheduled workflows

GitHub turns off scheduled workflows in a repository with no activity for 60 days. If that
happens, turn them back on:

```bash
gh workflow enable update-formulae.yml -R buidangminh23/homebrew-tap
gh workflow enable update-casks.yml -R buidangminh23/homebrew-tap
```

## License

MIT
