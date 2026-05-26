# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A [chezmoi](https://www.chezmoi.io/) dotfiles repo managing macOS shell configuration. chezmoi maps files with `dot_` prefixes to their `~/.` equivalents (e.g. `dot_zshrc` → `~/.zshrc`), and `.tmpl` files are Go templates rendered with data from `.chezmoidata/`.

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
chezmoi run run_onchange_darwin-install-packages.sh.tmpl
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
| `.chezmoidata/packages.yaml` | — | Data file: Homebrew brews/casks + Mac App Store apps to install |
| `run_onchange_darwin-install-packages.sh.tmpl` | — | Script: runs `brew bundle` whenever `packages.yaml` changes |

## Template system

`run_onchange_darwin-install-packages.sh.tmpl` is a Go template that reads from `.chezmoidata/packages.yaml`. To add a new Homebrew package, edit `packages.yaml` — the install script will re-run automatically on the next `chezmoi apply` because chezmoi hashes the rendered output to detect changes.

The `private_` prefix on `dot_config/cmux/private_cmux.json` tells chezmoi to set `chmod 600` on the destination file.

## Font convention

The only font is **Berkeley Mono** (paid, installed via `run_onchange_install-berkeley-mono.sh.tmpl` which fetches the .otf files from a 1Password Document item named `Berkeley Mono` — the binary deliberately stays out of this public repo).

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
