# Brewfile — curated, declarative manifest for the new Mac.
# Grouped by type; no per-line comment spam (run `brew desc <name>` if unsure).
# Intentionally NO php/node/npm formulae: PHP is Yerd, Node is nvm.
# Intentionally NO docker: OrbStack provides the docker + compose CLIs.

# ── Taps ──
# trusted: true authorizes brew to run each tap's update-check code. Both are
# official first-party org taps for software installed below — safe to trust.
# (carapace is in homebrew-core now — no tap needed.)
tap "crowdin/crowdin", trusted: true
tap "muxy-app/tap", trusted: true

# ── Formulae: core CLI ──
brew "git"
brew "gh"
brew "git-delta"
brew "lazygit"
brew "jq"
brew "ripgrep"
brew "fd"
brew "bat"
brew "eza"
brew "fzf"
brew "zoxide"
brew "tldr"
brew "wget"
brew "neovim"
brew "starship"
brew "chezmoi"

# ── Formulae: shell completion (Ghostty-native, replaces Fig/Kiro) ──
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"
brew "atuin"
brew "carapace"
# fzf-tab is not on Homebrew — auto-cloned via chezmoi (.chezmoiexternal.toml)

# ── Formulae: runtimes / version managers ──
brew "nvm"
brew "pyenv"
brew "pyenv-virtualenv"
brew "ruby"

# ── Formulae: web / WordPress / Pressbooks ──
brew "wp-cli"
brew "mkcert"
brew "libpq"
brew "crowdin/crowdin/crowdin@4"

# ── Formulae: mobile (Xcode / Android Studio) ──
brew "cocoapods"
brew "fastlane"
brew "watchman"
brew "bundletool"
brew "ios-deploy"
brew "xcodegen"
brew "ccache"

# ── Casks: editors & terminal ──
cask "zed"                   # main editor
cask "visual-studio-code"
cask "muxy"                  # terminal multiplexer (via muxy-app/tap)
cask "ghostty"

# ── Casks: AI ──
cask "claude"                # Claude desktop app
cask "claude-code"           # Claude Code CLI (self-updating; env var in setup step 5)

# ── Casks: dev tools ──
cask "android-studio"        # priority — pairs with Xcode (App Store)
cask "orbstack"
cask "tableplus"             # DB GUI
cask "dbngin"                # local DB version manager
cask "httpie"               # API client (replaces bruno)
cask "transmit"              # SFTP/S3
cask "ngrok"
cask "localsend"

# ── Casks: productivity & apps ──
cask "1password"
cask "1password-cli"        # op CLI — required by chezmoi onepasswordRead + setup scripts
cask "raycast"
cask "rectangle"
cask "maccy"
cask "todoist"
cask "notion"
cask "obsidian"              # notes
cask "sketch"               # design
cask "libreoffice"
cask "ente-auth"             # 2FA / TOTP
cask "google-drive"          # syncs ~/Documents from the cloud
cask "daisydisk"             # disk usage
cask "drata-agent"           # compliance agent (work)

# ── Casks: comms & media ──
cask "slack"
cask "telegram"
cask "discord"
cask "spotify"
cask "zoom"
# ChatMate Pro for WhatsApp → Mac App Store only (see MIGRATION.md).
# The brew cask "chatmate-for-whatsapp" is the deprecated/disabled non-Pro app.

# ── Casks: browsers & network ──
cask "firefox"
cask "google-chrome"
cask "tunnelbear"            # VPN
cask "vlc"

# ── Casks: Java (Android / build toolchains) ──
cask "zulu@17"

# ── Casks: system / hardware ──
cask "hp-easy-start"         # HP printer software

# ── Mac App Store ──
# Sign in to the App Store first, then uncomment. Xcode is huge — start it early.
# Find IDs with `mas search "<name>"`.
# mas "Xcode", id: 497799835

# ── npm globals (Node CLIs) — installed AFTER nvm, NOT here ──
# node/npm don't exist when `brew bundle` runs (node comes from nvm later), so
# these can't be brew-bundled — they'd fail and abort the run. Install them once
# `nvm install --lts` is done (see MIGRATION.md):
#   npm i -g @rynfar/meridian eas-cli corepack
# npm "@rynfar/meridian"   # the :3456 proxy claude/opencode route through
# npm "eas-cli"
# npm "corepack"

# ── uv tools — installed AFTER uv exists, NOT here ──
#   uv tool install graphifyy
# uv "graphifyy"

# ─────────────────────────────────────────────────────────────────────────
# OPTIONAL — uncomment anything you still want. Kept here so nothing is
# silently lost, but not installed by default (keeps the base install lean).
# ─────────────────────────────────────────────────────────────────────────
# brew "awscli"
# brew "aws-sam-cli"
# brew "act"
brew "ffmpeg"
# brew "exiftool"
brew "jpegoptim"
brew "optipng"
brew "pngquant"
# brew "qpdf"
# brew "pdftk-java"
brew "p7zip"
# brew "dos2unix"
# brew "subversion"
# brew "inetutils"
# brew "helix"
brew "ollama"
brew "pipx"
# cask "temurin@8"
# cask "miniconda"
cask "calibre"
cask "hiddenbar"
# cask "swiftbar"
cask "whisky"
cask "copilot-cli"
# npm "@google/gemini-cli"
# npm "@github/copilot"
# npm "@hubspot/cli"
# npm "husky"   → install post-nvm with the other npm globals (see MIGRATION.md)
# uv "kimi-cli"
#
# Deliberately dropped (do NOT re-add):
#   brew "docker"      → OrbStack provides docker + compose
#   brew "exa"         → superseded by eza
#   cask "fig"         → Fig/Kiro lineage; fights Ghostty. Replaced by carapace/atuin
#   cask "flutter"     → dart no longer used
#   tap  "dart-lang/dart"
