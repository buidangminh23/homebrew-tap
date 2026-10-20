# buidangminh23/tap

Homebrew formulae for tools published by [buidangminh23](https://github.com/buidangminh23).

| Formula | Tool |
|---|---|
| `codex-mcp-bridge` | [codex-mcp-bridge](https://github.com/buidangminh23/codex-mcp-bridge): two-way MCP bridge between Claude and Codex |

## Install

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

## Upgrade and uninstall

```bash
brew upgrade codex-mcp-bridge
brew uninstall codex-mcp-bridge
```

Uninstalling removes the commands only. Client registrations and the bridge's state in `~/.codex`
stay until you remove them.

## How the formula follows releases

`.github/workflows/update-formulae.yml` runs every three hours and on demand. It reads the latest
version of `@minhspark/codex-mcp-bridge` from npm, checks the downloaded tarball against the
registry's SHA-512 integrity, writes the new URL and SHA-256, then installs, tests and audits the
formula on macOS before committing. A failed check leaves the formula where it was. To follow a
release at once:

```bash
gh workflow run update-formulae.yml -R buidangminh23/homebrew-tap
```

The same bump runs locally with `scripts/update-codex-mcp-bridge.sh`.

GitHub turns off scheduled workflows in a repository with no activity for 60 days. If that
happens, turn it back on with `gh workflow enable update-formulae.yml -R buidangminh23/homebrew-tap`.

## License

MIT
