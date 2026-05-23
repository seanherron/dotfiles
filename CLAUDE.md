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
| `dot_zprofile` | `~/.zprofile` | Login shell: Homebrew PATH setup |
| `dot_zshrc` | `~/.zshrc` | Interactive shell: history, completions, plugins, aliases |
| `dot_zsh_plugins.txt` | `~/.zsh_plugins.txt` | Antidote plugin list (zsh-autosuggestions, zsh-syntax-highlighting) |
| `dot_config/starship.toml` | `~/.config/starship.toml` | Starship prompt config |
| `dot_config/cmux/private_cmux.json` | `~/.config/cmux/cmux.json` | cmux terminal multiplexer config (JSONC format) |
| `.chezmoidata/packages.yaml` | — | Data file: Homebrew brews and casks to install |
| `run_onchange_darwin-install-packages.sh.tmpl` | — | Script: runs `brew bundle` whenever `packages.yaml` changes |

## Template system

`run_onchange_darwin-install-packages.sh.tmpl` is a Go template that reads from `.chezmoidata/packages.yaml`. To add a new Homebrew package, edit `packages.yaml` — the install script will re-run automatically on the next `chezmoi apply` because chezmoi hashes the rendered output to detect changes.

The `private_` prefix on `dot_config/cmux/private_cmux.json` tells chezmoi to set `chmod 600` on the destination file.

## Font convention

The configured font for all code editors and terminals is **JetBrainsMono Nerd Font** (cask `font-jetbrains-mono-nerd-font`). When adding a new dotfile for any code editor or terminal emulator that supports font configuration, always set the font to JetBrainsMono Nerd Font. Use `"JetBrainsMono Nerd Font"` as the font family string (this is the correct PostScript name for the Nerd Font variant).

## Color convention

The default color scheme everywhere is **Catppuccin Mocha**. When adding a new dotfile for anything that supports theming (terminal, editor, prompt, pager, file lister, fuzzy finder, syntax highlighter, etc.), apply the Mocha variant — never Latte/Frappé/Macchiato or another palette. Prefer a built-in theme name (e.g. Ghostty's `"Catppuccin Mocha"`, bat's `"Catppuccin Mocha"`) over hand-rolled hex; fall back to the official Catppuccin port for that tool (https://github.com/catppuccin) when no built-in exists. The hex palette is defined once in `dot_config/starship.toml` under `[palettes.catppuccin_mocha]` — copy from there to keep colors consistent.
