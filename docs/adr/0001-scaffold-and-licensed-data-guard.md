# 0001. Mirror the library's docs layout and copy its licensed-data guard

- **Status:** Proposed
- **Date:** 2026-11-24
- **Issue:** #1

## Context

This public repo consumes `sports_ingest` and will handle Evolving-Hockey and PuckPedia data, licensed
to the user personally. The library already has a docs layout and a guard (its ADRs 0005 and 0014).
Issue #1 asks for both here, before any app code exists.

## Decision

- Keep the library's layout: a short README as an index, one file per topic in `docs/`, ADRs numbered
  by issue.
- Copy `script/licensed-data-guard`, its hook and its spec. It runs pre-commit and in CI, over tracked
  files and every commit in a PR.
- Pin the library's Ruby version and use RSpec, only to test the guard for now.
- Edit `CHANGELOG.md` under "Unreleased" directly, as the issue's Definition of Done says.

## Alternatives considered

- **Share the guard through the gem or a submodule.** Avoids drift, but hooks run before the bundle is
  installed, and the gem excludes repo tooling on purpose.
- **Changelog fragments, as the library uses.** They solve conflicts between parallel PRs; these
  issues are a mostly linear chain, and fragments need rake tooling.
- **No test tooling until the app exists.** The guard would be untested in this repo.

## Consequences

- The two guard copies can drift: when the library's patterns change, copy them here.
- The guard is a heuristic, and `--no-verify` skips the hook; CI and review are the backstop.
- The app may revisit Ruby tooling in its own ADR.
