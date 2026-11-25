# frozen_string_literal: true

require_relative "../../../script/claude/lib/issues"

RSpec.describe ReadyIssues do
  def issue(**over)
    {"number" => 2, "title" => "[C2-01] Scoring rules JSON", "body" => "", "labels" => [],
     "author" => "someone", "association" => "OWNER"}.merge(over.transform_keys(&:to_s))
  end

  def reason(issue, **over)
    described_class.skip_reason(issue, blockers: {}, status: "Todo", pr_issues: [], branches: [], **over)
  end

  it "names the label and branch from the title" do
    expect(described_class.label(issue)).to eq("C2-01")
    expect(described_class.branch_name(issue)).to eq("c2-01-scoring-rules-json")
  end

  it "keeps blockers in other repos apart from this repo's" do
    body = "## Blocked by\r\n- BryceARich/sports_ingest#33 [M4-02] x\r\n- #2 y\r\n<!-- #9 -->\r\n\r\n## Definition of Done\r\n#7"
    expect(described_class.body_blockers(issue(body: body)))
      .to eq(["BryceARich/sports_ingest#33", "BryceARich/draft_tools#2"])
  end

  it "has no blockers when the body says Nothing" do
    expect(described_class.body_blockers(issue(body: "## Blocked by\nNothing."))).to eq([])
  end

  it "is ready once every blocker is closed" do
    expect(reason(issue, blockers: {"BryceARich/sports_ingest#33" => "closed"})).to be_nil
  end

  it "skips an open blocker in another repo" do
    expect(reason(issue, blockers: {"BryceARich/sports_ingest#33" => "open"})).to eq("blocked by BryceARich/sports_ingest#33")
  end

  it "skips issues from people with no role on the repo" do
    expect(reason(issue(association: "NONE"))).to match(/no role/)
  end

  it "skips issues already taken" do
    expect(reason(issue, status: "In Progress")).to eq("status is In Progress")
    expect(reason(issue, pr_issues: [2])).to eq("has an open PR")
    expect(reason(issue, branches: ["claude/c2-01-other"])).to eq("branch c2-01-* exists")
  end

  it "picks the design model for needs-decision issues" do
    expect(described_class.model_for(issue(labels: ["needs-decision"]))).to eq("claude-opus-5-5")
    expect(described_class.model_for(issue)).to eq("claude-sonnet-5-5")
  end
end
