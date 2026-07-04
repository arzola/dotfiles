# dotfiles

chezmoi-managed. Bootstrap on a new Mac:

```bash
chezmoi init --apply arzola/dotfiles
```

- `dot_zshrc` → `~/.zshrc` (starship + carapace/fzf-tab/atuin/autosuggestions;
  PHP=Yerd, Node=nvm; Meridian proxy on :3456)
- `.chezmoiexternal.toml` → auto-clones fzf-tab
- `.chezmoiignore` → keeps secrets/session-state out of this public repo
  (restore `.netrc`, `gh hosts.yml`, `.ssh/config` from the vault)
