# Picking back up

Start here after time away. Setup and commands are in [`SETUP.md`](SETUP.md).

_Last updated: 2026-11-24 (C2-00)._

## Current status

C2-00 (this scaffold) only. **There is no app to run yet**, so setup ends at passing specs.
Getting it running on a clean machine from this file is carried over to C2-05 (#6).

## Next issues

All are on GitHub: <https://github.com/BryceARich/draft_tools/issues>.

| Issue | Waits on |
|---|---|
| C2-01 Scoring rules JSON (#2) | `sports_ingest` M4-02 |
| C2-02 Rescore history (#3) | #2, `sports_ingest` M4-03 |
| C2-03 Projection blend (#4) | #3, `sports_ingest` M4-04 |
| C2-04 Value over replacement (#5) | #4 |
| C2-05 Draft board UI (#6), C2-07 Hockey categories vs. points (#8) | #5 |
| C2-06 Mock draft board (#7) | #6 |

## Yearly draft-prep runbook

Once per draft season, in order. Steps marked _pending_ can't run yet; the issue that builds each one
replaces its text with the real command.

1. **Refresh ESPN cookies.** Log in at `fantasy.espn.com`, open the browser's developer tools
   (Application or Storage → Cookies), and copy `espn_s2` and `SWID` (keep the braces). In zsh, which
   keeps the values out of shell history:

   ```zsh
   read -rs "SPORTS_INGEST_ESPN_S2?espn_s2: "; export SPORTS_INGEST_ESPN_S2
   read -rs "SPORTS_INGEST_ESPN_SWID?SWID: "; export SPORTS_INGEST_ESPN_SWID
   ```

   To check them, run `bin/console` in a `sports_ingest` checkout from that same shell and, with your
   league ID and season (football: start year; hockey: end year):

   ```ruby
   require "sports_ingest/espn"
   SportsIngest::ESPN::Client.new(game: :football).league(LEAGUE_ID, season: 2026, views: %w[mSettings])
   ```

   Bad or expired cookies on a private league raise `SportsIngest::AuthError`.
2. **Take a snapshot** _(pending: `sports_ingest` M7-01)_. Write the player pool, stats, projections
   and league settings to a dated folder **outside this repo**. It can hold licensed data.
3. **Load the scoring rules** _(pending: C2-01)_. From ESPN league settings or the rules JSON. Check
   the result against ESPN's scoring page.
4. **Run a mock draft** _(pending: C2-05, C2-06)_. Do one from the snapshot with the network off
   (`sports_ingest` M7-02) before draft day.

## Known gotchas

- **ESPN cookies expire.** Auth errors mean it's time for step 1 again.
- **Season names differ:** 2026-27 hockey is `2027` on ESPN, the 2026 football season is `2026`.
- **Claude sessions** may get macOS's Ruby 2.6. Use `mise exec -- bundle exec rspec`.
