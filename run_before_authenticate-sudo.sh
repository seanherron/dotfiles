#!/bin/bash
# Authenticate sudo ONCE, before chezmoi writes any files or runs any other
# script. `run_` (no once_/onchange_) means this runs on every `chezmoi apply`;
# `before_` orders it first. chezmoi runs every child script attached to its own
# controlling terminal, and macOS's default per-tty sudo timestamp is keyed to
# that terminal — so this single prompt is then valid for every later sudo the
# apply makes (the package install and the /etc/pam.d/sudo_local hook), with no
# system-wide sudoers change. A long `brew bundle` is the only thing that could
# outlast the default 5-min ticket; run_onchange_install-packages.sh.tmpl keeps
# the credential alive across it (see its keepalive loop).
#
# Caveat: this relies on a controlling tty. A non-interactive apply (piped, cron,
# `curl | sh` bootstrap) has none, so sudo falls back to per-process tickets and
# later scripts may re-prompt — not a concern for interactive macOS use, and the
# Linux bootstrap path installs nothing that needs sudo.
#
# No-op (no prompt) if a valid credential is already cached. Gated to darwin via
# .chezmoiignore (Linux remotes never install sudo-touching things).
set -euo pipefail
sudo -n true 2>/dev/null || sudo -v
