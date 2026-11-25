# Setup and reference

## Fresh machine (Mac)

```bash
xcode-select --install        # skip if already installed
brew install mise libyaml openssl@3 git
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc && exec zsh
git clone https://github.com/BryceARich/draft_tools.git
cd draft_tools
bin/setup
bundle exec rspec
```

`bin/setup` installs Ruby from `.ruby-version` and the gems, lets mise read `.ruby-version`, and turns
on the pre-commit licensed-data guard. There is no app to start yet ([`RESUME.md`](RESUME.md)).

## Commands

| What | Command |
|---|---|
| Tests | `bundle exec rspec` |
| Check for licensed data | `script/licensed-data-guard --all` (the hook checks staged files) |
| Issues ready to start (`--all` for the rest) | `script/claude/ready-issues` |
| Start sessions for them (Claude desktop app) | `/spawn_unblocked [max] [--dry-run]` |

## Where things live

| Path | Contents |
|---|---|
| `README.md` | Index of the docs |
| `CLAUDE.md`, `CONTRIBUTING.md` | Rules and workflow |
| `docs/` | RESUME, SETUP, ARCHITECTURE, ADRs; one file per topic |
| `.github/` | Issue and PR templates, CODEOWNERS, CI |
| `script/licensed-data-guard`, `.githooks/` | Licensed-data guard and its hook |
| `.claude/commands/`, `script/claude/` | `/spawn_unblocked` and the script it uses |
| Exports, snapshots | **Outside the repo**; `/data/`, `/exports/`, `/snapshots/` are gitignored |
