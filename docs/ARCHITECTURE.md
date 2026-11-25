# Architecture

> **Status:** plan only; no app code exists. When code lands and differs, update this file in the
> same PR.

```mermaid
flowchart LR
    lib["sports_ingest<br/>ESPN, stats, projections"] --> rules["Scoring rules<br/>C2-01"]
    lib --> history["Rescored history<br/>C2-02"]
    rules --> history
    history --> blend["Projection blend<br/>C2-03"]
    lib --> blend
    blend --> value["Value over replacement<br/>C2-04"]
    value --> board["Draft board UI<br/>C2-05"]
    board --> mock["Mock draft board<br/>C2-06"]
```

- **Input** comes only from `sports_ingest`, live or from a snapshot. This repo doesn't fetch,
  cache or match players itself.
- **Scoring rules** come from ESPN league settings or a JSON file shaped like the ScoringSystem tab.
- **Values** depend on league size and roster slots. Whether hockey also needs categories valuation
  is open (C2-07).
- **Output** that includes licensed data stays outside the repo
  ([ADR 0001](adr/0001-scaffold-and-licensed-data-guard.md)).

Not decided yet: the UI technology (C2-05) and how the app depends on the gem (C2-01).
