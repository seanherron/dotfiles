# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A [chezmoi](https://www.chezmoi.io/) dotfiles repo managing shell configuration on **two profiles**:

- **macOS** (primary workstation) — the full setup: GUI app configs, Homebrew casks, Mac App Store apps, macOS defaults, fonts.
- **Linux** (remote servers reached over SSH) — a lighter subset: the same CLI toolchain via Homebrew-on-Linux (linuxbrew), but no GUI apps, no fonts, no macOS defaults.

chezmoi maps files with `dot_` prefixes to their `~/.` equivalents (e.g. `dot_zshrc` → `~/.zshrc`), and `.tmpl` files are Go templates rendered with data from `.chezmoidata/`.

### How the two profiles are split

The split is driven entirely by `{{ "{{" }} .chezmoi.os {{ "}}" }}` (`"darwin"` vs `"linux"`):

- **`.chezmoiignore`** is a template. On non-darwin it ignores the macOS-only artifacts (`Library` editor settings, `.config/ghostty`, `.config/cmux`, the font/extension installers, `run_onchange_macos-defaults.sh`, and the sudo scripts), so they never deploy to Linux.
- **Single sudo prompt per apply**: `run_before_authenticate-sudo.sh` does one `sudo -v` before anything else runs (darwin-only, gated in `.chezmoiignore`). chezmoi runs every child script attached to its own controlling terminal, and macOS's default per-tty sudo timestamp is keyed to that terminal, so that one prompt is then valid for every later sudo the apply makes (casks, the `sudo_local` hook) — **no sudoers change, nothing persistent, nothing to clean up**. The only gap, a `brew bundle` longer than the default 5-min ticket, is covered by the keep-alive loop already in `install-packages`. (This relies on a controlling tty; a non-interactive apply — cron, piped, `curl | sh` — would fall back to per-process tickets and could re-prompt, which is irrelevant to interactive macOS use and to the sudo-free Linux bootstrap.)
- **`run_onchange_install-packages.sh.tmpl`** branches on OS: macOS installs `brews` + `darwinBrews` + `casks` + `mas` (it also keeps the sudo credential alive across a long `brew bundle`); Linux bootstraps Homebrew-on-Linux if missing, then installs the cross-platform `brews` only. It also branches on the **`.profile`** data value (`personal` vs `work`): `personalCasks` are only installed when `profile == "personal"`, so work machines skip them. These are GUI apps that on a work machine are provided (root-owned) by IT/MDM and self-update — `1password`, `google-chrome`, `visual-studio-code`, `cursor`, `claude`, `chatgpt`, `codex-app`. Letting `brew bundle` manage them on work just causes upgrade churn, and each upgrade of a root-owned app needs sudo (the cause of repeated password prompts during `chezmoi apply`). Their CLI counterparts (`claude-code`, `codex`, `1password-cli`) install user-owned and stay in cross-profile `casks`.
- **`private_dot_ssh/private_config.tmpl`** gates the Apple-only `UseKeychain` directive behind darwin (it errors out on Linux ssh).
- **`dot_zprofile`** locates Homebrew across Apple Silicon, Intel, and linuxbrew prefixes — plain runtime checks, no templating.
- **`dot_zshrc`** and **`dot_gitconfig.tmpl`** need no OS branching: the 1Password SSH-agent block self-guards on a socket path that doesn't exist on Linux, and git signing falls back to `ssh-keygen` (via a forwarded 1Password agent on trusted dev boxes) when the macOS 1Password app isn't present.

When adding a file, decide which profile(s) it belongs to: macOS-only → add it to the `.chezmoiignore` non-darwin block; cross-platform → leave it (it deploys everywhere); needs to differ → make it a `.tmpl` and branch on `.chezmoi.os`.

## Bootstrap (first-time setup)

**macOS** (with [Homebrew](https://brew.sh) already installed):

```bash
brew install chezmoi
chezmoi init --apply seanherron
```

**Linux remote server** (chezmoi runs on the box; it bootstraps Homebrew-on-Linux itself on first apply):

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply seanherron
```

## Key commands

```bash
# Apply all dotfiles to the home directory
chezmoi apply

# Preview what would change (dry run)
chezmoi diff

# Edit a managed file and apply immediately
chezmoi edit ~/.zshrc

# Add a new file to be managed
chezmoi add ~/.somerc

# Re-run the package install script (normally only runs when it changes)
chezmoi run run_onchange_install-packages.sh.tmpl
```

## Structure

| Path | Maps to | Purpose |
|------|---------|---------|
| `dot_zprofile` | `~/.zprofile` | Login shell: Homebrew PATH, XDG dirs, GNU tools on PATH |
| `dot_zshrc` | `~/.zshrc` | Interactive shell: history, completions, plugins, aliases, mise/atuin/direnv |
| `dot_zsh_plugins.txt` | `~/.zsh_plugins.txt` | Antidote plugin list (fzf-tab, zsh-autosuggestions, zsh-syntax-highlighting) |
| `dot_config/starship.toml` | `~/.config/starship.toml` | Starship prompt config |
| `dot_config/cmux/private_cmux.json` | `~/.config/cmux/cmux.json` | cmux terminal multiplexer config (JSONC format) |
| `dot_config/lazygit/config.yml` | `~/.config/lazygit/config.yml` | lazygit Nord theme + delta as the pager |
| `dot_config/btop/btop.conf` | `~/.config/btop/btop.conf` | btop Nord theme + defaults |
| `dot_editorconfig` | `~/.editorconfig` | Global EditorConfig fallback |
| `.chezmoidata/packages.yaml` | — | Data file: `brews` (cross-platform), `darwinBrews` (macOS-only), `casks` + `mas` (macOS-only), `personalCasks` (macOS + `profile == "personal"` only) |
| `run_onchange_install-packages.sh.tmpl` | — | Script: runs `brew bundle` whenever `packages.yaml` changes; branches macOS vs Linux |
| `run_before_authenticate-sudo.sh` | — | Script (macOS): runs first on every apply; one `sudo -v` that the rest of the apply reuses via the shared per-tty ticket (no sudoers change) |

## Template system

`run_onchange_install-packages.sh.tmpl` is a Go template that reads from `.chezmoidata/packages.yaml`. To add a new Homebrew package, edit `packages.yaml`: put cross-platform CLI tools under `brews` (installed on both profiles), macOS-only formulae under `darwinBrews`, GUI apps under `casks`, and GUI apps that are provided by IT/MDM on work machines (they install root-owned and self-update) under `personalCasks` (installed only when `profile == "personal"`, so brew doesn't fight MDM or trigger sudo prompts on work). The install script re-runs automatically on the next `chezmoi apply` because chezmoi hashes the rendered output to detect changes.

The `private_` prefix on `dot_config/cmux/private_cmux.json` tells chezmoi to set `chmod 600` on the destination file.

## Font convention

The only font is **Berkeley Mono** (paid, installed via `run_onchange_install-berkeley-mono.sh` which fetches the .otf files from a 1Password Document item named `Berkeley Mono` — the binary deliberately stays out of this public repo).

Nerd Font glyphs are **not used** anywhere in this setup. When adding a new dotfile for an editor or terminal that supports font configuration, use Berkeley Mono alone:

- Editors (CSS-style): `"Berkeley Mono, monospace"`
- Ghostty: single `font-family = "Berkeley Mono"` line
- Terminals / other apps: `"Berkeley Mono"`

When configuring tools that output decorative icons by default (e.g. eza's `--icons`, starship module symbols), disable them or replace with plain-text equivalents.

## Color convention

The default color scheme everywhere is **Nord**. When adding a new dotfile for anything that supports theming (terminal, editor, prompt, pager, file lister, fuzzy finder, syntax highlighter, etc.), apply Nord — prefer a built-in theme name (e.g. Ghostty's `"Nord"`, bat's `"Nord"`, btop's `"nord"`) over hand-rolled hex. The full hex palette is defined in `dot_config/starship.toml` under `[palettes.nord]` — copy from there to keep colors consistent.

Nord palette reference:
- Polar Night (backgrounds): `#2E3440` nord0, `#3B4252` nord1, `#434C5E` nord2, `#4C566A` nord3
- Snow Storm (foreground): `#D8DEE9` nord4, `#E5E9F0` nord5, `#ECEFF4` nord6
- Frost (blue/teal): `#8FBCBB` nord7, `#88C0D0` nord8, `#81A1C1` nord9, `#5E81AC` nord10
- Aurora (accents): `#BF616A` nord11 red, `#D08770` nord12 orange, `#EBCB8B` nord13 yellow, `#A3BE8C` nord14 green, `#B48EAD` nord15 purple
