# dotfiles

macOS shell + editor + terminal config, managed by [chezmoi](https://www.chezmoi.io/).

Themed end-to-end in [Catppuccin Mocha](https://catppuccin.com/) with [Berkeley Mono](https://berkeleygraphics.com/typefaces/berkeley-mono/) as the primary font (JetBrainsMono Nerd Font fallback for icon glyphs). Git commits are signed with an SSH key stored in 1Password.

## Quick start

On a fresh Mac, with [Homebrew](https://brew.sh) and the GitHub CLI already installed:

```bash
brew install chezmoi
chezmoi init --apply seanherron
```

`chezmoi init` will prompt for:

| Prompt           | What it's for                                                                 |
| ---------------- | ----------------------------------------------------------------------------- |
| `profile`        | `personal` or `work` — informational, available to templates as `{{ .profile }}` |
| `name`           | Git author name (`user.name`)                                                 |
| `email`          | Git author email + principal in `~/.config/git/allowed_signers`               |
| `signingKey`     | Full SSH public key line (`ssh-ed25519 AAAA... comment`) from 1Password       |
| `githubUser`     | Used in `~/.ssh/config` and the dev-box stub                                  |

Answers persist to `~/.config/chezmoi/chezmoi.toml`. `chezmoi apply` later won't re-prompt.

## What's in here

| Path                                                  | Maps to                                                | Purpose                                                                         |
| ----------------------------------------------------- | ------------------------------------------------------ | ------------------------------------------------------------------------------- |
| `dot_zprofile`                                        | `~/.zprofile`                                          | Login shell — Homebrew PATH                                                     |
| `dot_zshrc`                                           | `~/.zshrc`                                             | Interactive shell — history, completions, plugins, aliases, 1Password SSH sock  |
| `dot_zsh_plugins.txt`                                 | `~/.zsh_plugins.txt`                                   | [Antidote](https://getantidote.github.io/) plugin list                          |
| `dot_gitconfig.tmpl`                                  | `~/.gitconfig`                                         | Git identity + SSH commit signing (1Password locally, ssh-keygen on remotes)    |
| `dot_config/git/allowed_signers.tmpl`                 | `~/.config/git/allowed_signers`                        | Lets `git log --show-signature` verify your own commits                         |
| `dot_config/starship.toml`                            | `~/.config/starship.toml`                              | Starship prompt — two-line, Catppuccin Mocha palette                            |
| `dot_config/ghostty/config`                           | `~/.config/ghostty/config`                             | Ghostty terminal — Berkeley Mono + JetBrainsMono Nerd Font fallback             |
| `dot_config/cmux/private_cmux.json`                   | `~/.config/cmux/cmux.json`                             | cmux config (commented template scaffold, 0600)                                 |
| `dot_config/bat/config`                               | `~/.config/bat/config`                                 | bat — Catppuccin Mocha theme                                                    |
| `dot_config/eza/theme.yml`                            | `~/.config/eza/theme.yml`                              | eza colors                                                                      |
| `dot_config/lazygit/config.yml`                       | `~/.config/lazygit/config.yml`                         | lazygit — Catppuccin Mocha + delta as the pager                                 |
| `dot_config/btop/btop.conf`                           | `~/.config/btop/btop.conf`                             | btop — Catppuccin Mocha theme + sane defaults                                   |
| `dot_editorconfig`                                    | `~/.editorconfig`                                      | Global EditorConfig fallback for projects without their own                      |
| `private_dot_ssh/private_config.tmpl`                 | `~/.ssh/config` (0700/0600)                            | SSH — 1Password IdentityAgent, ForwardAgent off, dev-box stub                   |
| `Library/Application Support/Code/User/settings.json` | same path under `~`                                    | VSCode — Claude Code panel layout, Catppuccin, format-on-save                   |
| `Library/Application Support/Code/User/keybindings.json` | same path under `~`                                 | VSCode — `cmd+j` editor ↔ Claude panel ping-pong                                |
| `Library/Application Support/Cursor/...`              | same paths under `~`                                   | Cursor — same settings/keybindings minus the Claude Code extension binding      |
| `.chezmoidata/packages.yaml`                          | —                                                      | Homebrew brews + casks to install (consumed by the package script)              |
| `.chezmoi.toml.tmpl`                                  | rendered once into `~/.config/chezmoi/chezmoi.toml`    | The init prompts above                                                          |
| `run_onchange_darwin-install-packages.sh.tmpl`        | runs on `chezmoi apply` when its hash changes          | `brew bundle` from `packages.yaml`                                              |
| `run_onchange_install-vscode-extensions.sh.tmpl`      | same                                                   | Installs Claude Code, 1Password, GitLens, GitHub PRs, Error Lens, EditorConfig, spell checker |
| `run_onchange_install-cursor-extensions.sh.tmpl`      | same                                                   | Same set, minus the Claude Code extension                                       |
| `run_onchange_install-berkeley-mono.sh.tmpl`          | same                                                   | Fetches Berkeley Mono from a 1Password Document and installs to `~/Library/Fonts/` |
| `CLAUDE.md`                                           | not deployed (in `.chezmoiignore`)                     | Project guidance for the Claude Code AI                                         |
| `README.md`                                           | not deployed                                           | This file                                                                       |

## chezmoi cheatsheet

```bash
chezmoi diff                       # preview what would change without applying
chezmoi apply                      # write everything to ~/
chezmoi edit ~/.zshrc              # edit a managed file and apply on save
chezmoi add ~/.somerc              # bring a new file under management
chezmoi update                     # git pull + apply in one shot
chezmoi cd                         # drop into this repo's working dir
```

## Conventions

- **Theme**: Catppuccin Mocha everywhere. Prefer a built-in theme name (e.g. Ghostty's `Catppuccin Mocha`, bat's `Catppuccin Mocha`). The hex palette lives once in `dot_config/starship.toml` under `[palettes.catppuccin_mocha]`.
- **Font**: Berkeley Mono primary, JetBrainsMono Nerd Font fallback. Always declare both in font-family strings — Berkeley Mono ships without Nerd Font glyphs, so Starship/eza icons need the fallback for per-character resolution. See `CLAUDE.md` for the exact pattern in each editor/terminal.

## CLI utilities

Every tool below is installed via `packages.yaml` and configured by `dot_zshrc` / `dot_zprofile` / its own `dot_config/` entry. Examples are written assuming a fresh `chezmoi apply` — copy-paste should Just Work.

### git-delta — prettier diffs

Wired into `~/.gitconfig` as both the pager and the `git add -p` filter. Every `git diff`, `git log -p`, `git show`, and `git stash show -p` is syntax-highlighted (Catppuccin Mocha) with line numbers and section navigation.

```bash
git diff                          # delta is the pager — n/N jumps between files
git log -p -- src/foo.rs          # syntax-highlighted history for one file
git show HEAD                     # same treatment for a single commit
git -c delta.side-by-side=true diff   # one-off side-by-side view
```

To turn delta off for a single command, pipe through `cat`: `git --no-pager diff` or `git -c core.pager=cat diff`.

### gh — GitHub CLI

```bash
gh auth login                     # one-time: pick "SSH" and reuse your 1Password key
gh pr create --fill               # title/body from the latest commit
gh pr view --web                  # open the PR for the current branch in a browser
gh pr checkout 42                 # check out PR #42 as a local branch
gh pr checks                      # CI status for the current branch
gh repo clone seanherron/dotfiles
gh issue list --assignee @me
gh run watch                      # tail the most recent workflow run
```

### fzf-tab — fzf-powered tab completion

Press `<TAB>` after any command and the completion menu becomes an fzf popup with previews. Listed first in `dot_zsh_plugins.txt` because it has to hook the completion system before zsh-autosuggestions and zsh-syntax-highlighting wrap zle.

```bash
cd <TAB>                          # popup with directory previews (eza tree)
git checkout <TAB>                # branch list, fuzzy-filterable
kill <TAB>                        # process list, fuzzy-filterable
export PA<TAB>                    # env-var names with current values previewed
ssh <TAB>                         # hosts from ~/.ssh/config
```

Keys inside the popup: type to filter, `<TAB>` to confirm, `<` / `>` to switch between completion groups (e.g. local branches vs remote branches), `?` to toggle the preview window.

### tealdeer (`tldr`) — practical man-page examples

`man` tells you every flag; `tldr` shows you the five commands you actually want.

```bash
tldr --update                     # first-time and occasional: refresh the cache
tldr tar                          # `tar -xzf …`, `tar -czf …`, etc.
tldr ffmpeg                       # common transcodes without reading 1k lines of man
tldr ssh                          # the actually-useful invocations
```

The cache lives at `~/.cache/tealdeer`; `tldr --update` is the only maintenance.

### mas — Mac App Store CLI

`mas` lets you put App Store apps into the same `packages.yaml` flow as brews and casks. The install script (`run_onchange_darwin-install-packages.sh.tmpl`) renders each entry as a Brewfile `mas` line.

```bash
mas search Xcode                  # find the numeric ID (first column)
mas list                          # what's already installed via the App Store
```

Add to `.chezmoidata/packages.yaml`:

```yaml
mas:
  - '497799835:Xcode'
  - '1451685025:WireGuard'
```

Format is `'<id>:<App Name>'`. You must be signed in to the App Store on the machine for `mas` to install anything — `mas account` shows the current user.

### atuin — searchable shell history

Replaces zsh's built-in `Ctrl+R` with a fuzzy, full-screen history search that's shared across terminals (no more "I ran that an hour ago in another tab"). Up-arrow keeps the vanilla behavior (recall the previous command verbatim) because `dot_zshrc` passes `--disable-up-arrow`.

```bash
# inside any prompt:
^R                                # open atuin's TUI; type to filter, Enter to run
atuin search docker run           # CLI search without entering the TUI
atuin stats                       # what your shell habits actually look like
atuin import auto                 # one-time: pull pre-atuin history from ~/.zsh_history
```

Cloud sync is **opt-in** and disabled by default — local-only out of the box. If you want sync across machines: `atuin register -u <user> -e <email>` then `atuin sync` on each machine.

### mise — universal version manager

One tool to manage Node, Python, Ruby, Go, Rust, Bun, etc. versions per project. Reads `.tool-versions` (asdf-compatible) or `.mise.toml`. Activated early in `dot_zshrc` so the right interpreter is on PATH before anything that resolves binaries.

```bash
mise use --global node@22         # set a global default
mise use node@20 python@3.12      # set per-directory (writes .mise.toml here)
mise install                      # install everything declared in .mise.toml
mise ls                           # what's active in this directory
mise exec node@18 -- node app.js  # one-off run with a different version
mise upgrade                      # pull newer minor/patch versions
```

Combine with direnv: `mise` handles tool versions; `direnv` handles env vars.

### direnv — per-directory env vars

Sources a `.envrc` file when you `cd` into a directory, unloads it when you leave. Hooked last in `dot_zshrc` so it wraps every other precmd hook.

```bash
cd ~/work/some-project
echo 'export DATABASE_URL=postgres://localhost/myapp' > .envrc
echo 'export AWS_PROFILE=staging' >> .envrc
direnv allow                      # confirm — required once per .envrc change

cd ~/work/some-project            # → direnv: loading .envrc
echo $DATABASE_URL                # → postgres://localhost/myapp
cd ..                             # → direnv: unloading
```

For secrets, never commit `.envrc` — gitignore it or use `dotenv` (`echo 'dotenv' > .envrc; direnv allow` then drop secrets in `.env`).

### lazygit — git TUI

```bash
lazygit                           # or `lg` (alias)
```

Stage hunks with `<space>`, commit with `c`, push with `P`, pull with `p`, rebase interactive with `e` on a commit, cherry-pick with `c` on a commit, view diffs with `<enter>`. `?` opens the full keybindings cheatsheet. Configured to use delta as the diff pager and Catppuccin Mocha for the UI.

### btop — system monitor

```bash
btop                              # CPU / memory / network / processes
```

Inside btop: `q` quits, `+`/`-` resize the process panel, `f` filters processes, `<enter>` shows process details, `m`/`p`/`n` toggles memory/processes/network panels. Catppuccin Mocha theme set via `dot_config/btop/btop.conf`.

### Modern CLI replacements (already aliased)

| Tool       | Replaces  | Aliased to    | Notes                                      |
| ---------- | --------- | ------------- | ------------------------------------------ |
| `eza`      | `ls`      | `ls`/`ll`/`lt` | icons, git status, tree view              |
| `bat`      | `cat`     | `cat`         | syntax highlighting, paging off            |
| `ripgrep`  | `grep`    | `grep`        | gitignore-aware, fast                      |
| `fd`       | `find`    | (no alias)    | use `fd pattern` instead of `find . -name` |
| `dust`     | `du`      | (no alias)    | tree view of biggest dirs first            |
| `procs`    | `ps`      | (no alias)    | colorized, tree view with `procs --tree`   |
| `sd`       | `sed`     | (no alias)    | sane regex syntax for find-and-replace     |
| `zoxide`   | `cd`      | `z` (and `cd`) | jumps to frecent dirs: `z dotf`            |

Examples for the un-aliased ones:

```bash
fd '\.tmpl$'                      # find templates anywhere below cwd
fd -t d node_modules              # find node_modules dirs
dust                              # biggest dirs in cwd
dust -d 2 ~/                      # 2-level deep summary of $HOME
procs                             # all processes, colorized
procs --tree firefox              # process tree filtered to firefox
echo 'foo bar foo' | sd 'foo' 'baz'   # → baz bar baz
sd '(\w+)@(\w+)' '$2:$1' file.txt # capture groups, written like literal regex
```

### hyperfine — command benchmarking

```bash
hyperfine 'rg foo' 'grep -r foo .'                  # head-to-head with warmup
hyperfine --warmup 3 'npm run build'                # warm caches before timing
hyperfine -L impl python,node 'tldr {impl}'        # parameter sweep
```

Reports mean, min/max, σ, and tells you which is faster with a confidence ratio.

### GNU coreutils + gnu-sed on macOS

`dot_zprofile` prepends `coreutils/libexec/gnubin` and `gnu-sed/libexec/gnubin` to PATH so `ls`, `date`, `sed`, etc. behave like Linux without the `g`-prefix dance.

```bash
date -d 'next friday'             # GNU date: relative-time parsing
sed -i 's/foo/bar/' file          # GNU sed: -i without a backup-suffix arg
ls --time-style=long-iso          # GNU ls flags
```

If you ever need the macOS BSD version specifically, the originals are still on PATH at `/usr/bin/sed`, `/bin/ls`, etc. — invoke by absolute path.

### .editorconfig

`dot_editorconfig` lays down a global `~/.editorconfig` so editors that respect the spec (VSCode/Cursor with the EditorConfig extension, JetBrains IDEs, Helix, Neovim with a plugin) fall back to LF + UTF-8 + trim-whitespace + 2-space indent when a project has no `.editorconfig` of its own. Per-language overrides for Go/Rust/Python/Make match each ecosystem's conventions.

Projects with their own `.editorconfig` win — this is just the floor.

## SSH + git signing

Commit signing uses an SSH key kept in 1Password's vault. The flow:

- **Locally** (1Password app installed): `~/.gitconfig` sets `gpg.ssh.program` to `/Applications/1Password.app/Contents/MacOS/op-ssh-sign`. Every `git commit` triggers a Touch ID prompt and signs without the key ever touching disk.
- **Remote dev box** (no 1Password installed, but you SSH'd in with `ForwardAgent yes`): the gitconfig template omits `gpg.ssh.program`, so git falls back to plain `ssh-keygen` which uses `$SSH_AUTH_SOCK`. That socket is your forwarded local 1Password agent — Touch ID still fires on your laptop.

`~/.ssh/config` keeps `ForwardAgent no` globally so a compromised remote can't sign as you. The file contains a commented `Host my-dev-box` block to copy-paste for trusted dev servers only.

The `gsign` alias prints the active signing key plus the keys visible to the agent — useful for diagnosing "wrong key" or "no key" errors.

## VSCode + Claude Code side-by-side

Settings put the integrated terminal in a right-side panel (`terminal.integrated.defaultLocation: view`, `workbench.panel.defaultLocation: right`) so `claude` running in that terminal sits next to your editor instead of below it. Keybindings:

- `cmd+j` — focus the panel from the editor; from the panel, jump back to the editor
- `cmd+shift+j` — toggle the panel (escape hatch)
- `cmd+\` — split editor right
- `cmd+k cmd+c` — focus first editor group (jump to code from anywhere)
- `cmd+k cmd+t` — focus Claude Code (provided by the `anthropic.claude-code` extension)

Cursor gets the same layout and keybindings minus the Claude Code shortcut.

## Berkeley Mono setup

Berkeley Mono is a paid font; the binary deliberately stays out of this public repo.

**One-time per Apple ID:**

1. In 1Password, create a **Document** item titled exactly `Berkeley Mono`. Drop your Berkeley Mono download into it — either the original `.zip` from Berkeley Graphics, or individual `.otf`/`.ttf` files. Any vault visible to your default account works.
2. Open 1Password → **Settings → Developer**, enable **Integrate with 1Password CLI**. This is what lets `op document get` use Touch ID without an `op signin` shell dance.

**Per machine:** `chezmoi apply` invokes `run_onchange_install-berkeley-mono.sh.tmpl`, which uses `op` to fetch the document, auto-detects whether it's a zip or a single font file, and unpacks the .otf/.ttf into `~/Library/Fonts/`. macOS picks them up immediately.

The script is a no-op (exits 0 with an explanation) when Berkeley Mono is already installed, when `op` isn't installed yet, or when you haven't signed into 1Password yet. The font-family fallback chain means everything still renders in JetBrainsMono Nerd Font in the meantime.

## Troubleshooting

### Berkeley Mono didn't install — how do I re-run the script?

`run_onchange_` scripts only re-execute when their rendered content changes (chezmoi hashes the rendered template and compares). If the script bailed out early (op not installed, not signed in, document not found), chezmoi still records that version as "run" and won't re-trigger on the next `chezmoi apply`.

**Fix:** clear chezmoi's script-run record and re-apply:

```bash
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```

This is the same recipe for re-running any other `run_onchange_*` script — package install, VSCode/Cursor extension install, etc. It wipes chezmoi's memory of every script-run; the next `chezmoi apply` will execute each `run_onchange_` script again, and each one's own logic (sentinel files, idempotent installs) handles the "already done" case.

### Commits aren't being signed

```bash
gsign
```

(Alias added by `dot_zshrc`.) Prints `user.signingkey` and the keys currently visible to the SSH agent. Common failures:

- Empty `ssh-add -L` output → 1Password's SSH agent isn't running. Open 1Password → **Settings → Developer** → enable **Use the SSH agent**, then quit and reopen 1Password.
- `signingkey` set but a different key appears in `ssh-add -L` → you pasted the wrong public key during `chezmoi init`. Re-run `chezmoi init --force` and re-paste from 1Password.
- Commits sign locally but not on a remote dev box → confirm your SSH connection was made with `ForwardAgent yes` (`grep -A3 "Host <name>" ~/.ssh/config`), and that the remote's `~/.gitconfig` does **not** set `gpg.ssh.program` (it should fall through to ssh-keygen, which uses the forwarded socket).

### VSCode extensions didn't install

Confirm the `code` CLI is on PATH (VSCode → Cmd+Shift+P → "Shell Command: Install 'code' command in PATH"), then re-run via the recipe above:

```bash
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```

Same idea for Cursor: install the `cursor` shell command first, then clear state.

### I changed `packages.yaml` but `brew bundle` didn't re-run

The chezmoi hash includes `packages.yaml`'s rendered output via the template's `range`, so editing the file should re-trigger the script automatically. If it doesn't (e.g. you reverted and then changed again to the same content), force it:

```bash
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```

### chezmoi prompted me again for `name`/`email`/`signingKey`

You probably ran `chezmoi init --force`, which intentionally re-prompts. To change one value without re-prompting all of them, edit `~/.config/chezmoi/chezmoi.toml` directly — that file is the rendered output of `.chezmoi.toml.tmpl` and is what every other template reads.
