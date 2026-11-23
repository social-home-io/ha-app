#!/usr/bin/env bash
# One-time devcontainer bootstrap (postCreateCommand).
#
# Claude Code for the remote user (not root) with Anthropic's native
# installer (https://code.claude.com/docs/en/setup): it lands in
# ~/.local/bin and auto-updates itself without sudo. The installer leaves
# the shell rc files alone, so add ~/.local/bin to PATH for bash and zsh
# here (VS Code terminals get it from remoteEnv in devcontainer.json); the
# grep guard keeps a re-run from adding the line twice.

set -euo pipefail

curl -fsSL https://claude.ai/install.sh | bash
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
	grep -qsF 'export PATH="$HOME/.local/bin:$PATH"' "$rc" ||
		echo 'export PATH="$HOME/.local/bin:$PATH"' >>"$rc"
done
