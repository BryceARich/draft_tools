# Contributing

Rules are in [`CLAUDE.md`](CLAUDE.md); setup is in [`docs/SETUP.md`](docs/SETUP.md).

- **Issues** are titled `[C2-yy] Title`; take them in that order unless "Blocked by" says otherwise.
- **Branches:** one per issue, named after its build order, cut from an up-to-date `main`.
  Never push to `main` directly.
- **Commits:** imperative subject under about 72 characters, with the build order:
  `Add scoring rules (C2-01)`. The body explains why.
- **Pull requests:** say `Closes #N`, and tick the Definition of Done or say why an item doesn't
  apply. `bundle exec rspec` must pass. Add a [`CHANGELOG.md`](CHANGELOG.md) entry.
- **Never commit** ESPN cookies, snapshots, or Evolving-Hockey / PuckPedia data.
- **Claude Code** works under the same rules, adds a `Co-Authored-By:` trailer, and doesn't merge.
