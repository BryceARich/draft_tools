# CLAUDE.md

**Read [`docs/RESUME.md`](docs/RESUME.md) first** for status, next issues and gotchas. Setup is in
[`docs/SETUP.md`](docs/SETUP.md), the design in [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

## What this project is

Draft tools for ESPN fantasy football and hockey. It is a consumer of the `sports_ingest` gem, which
does the fetching, caching and player matching. Don't re-implement those here; if the library lacks
something, open a consumer request in `sports_ingest`.

## Commands

```bash
bin/setup                          # Ruby, gems, pre-commit hook
bundle exec rspec                  # tests
script/licensed-data-guard --all   # check tracked files for licensed data
```

When these change, update this list and `docs/SETUP.md` together.

## Conventions

- Keep docs small: the README is an index, and each topic has its own file under `docs/`.
- Specs run offline. Every public method gets a YARD comment.
- A decision with real alternatives gets an ADR, `docs/adr/NNNN-slug.md`, numbered after its issue.
- Every change adds an entry under "Unreleased" in `CHANGELOG.md`.
- One branch per issue, named after its build order (`c2-01-scoring-rules`). Changes reach `main`
  only through PRs, never by direct push. The maintainer reviews and merges.
- Act as the `gh` account the maintainer is signed in with; never run `gh auth switch`.
- Secrets (`espn_s2`, `SWID`) come from the environment and are never committed or pasted in issues.

## The licensed-data rule

Evolving-Hockey and PuckPedia data is licensed to the user personally and **never enters git**: no
exports, and nothing derived from them (caches, snapshots, value boards). Keep all of it outside the
repo. Fixtures use the real column layouts with invented values. `script/licensed-data-guard` checks
this in a pre-commit hook and CI ([ADR 0001](docs/adr/0001-scaffold-and-licensed-data-guard.md)), but
it's a heuristic: if a staged file looks like a real export, stop and say so.

## Working on an issue

Read the issue and its "Blocked by" list, do only what it asks, check its Definition of Done, then
open a PR that says `Closes #N`. Update `docs/RESUME.md` when status changes.
