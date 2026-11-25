# frozen_string_literal: true

# Which issues are ready to start. Adapted from sports_ingest's script/claude, and simpler, except
# that blockers here can be in another repo. Stdlib Ruby (2.6+) plus the `gh` and `git` CLIs.
require "json"
require "open3"

Encoding.default_external = Encoding::UTF_8

module ReadyIssues
  REPO = "BryceARich/draft_tools"
  PROJECT = "1" # board number, under the repo owner
  TITLE_RE = /\A\[C(\d+)-(\d+)\]\s*(.*)\z/.freeze
  # The repo is public: only issues opened by people with a role on it may start a session, which
  # holds a GitHub token.
  TRUSTED_ASSOCIATIONS = %w[OWNER MEMBER COLLABORATOR].freeze
  DESIGN_LABEL = "needs-decision"
  MODEL_DEFAULT = "claude-sonnet-5-5"
  MODEL_DESIGN = "claude-opus-5-5"

  module_function

  # @param issue [Hash] an issue from {.all_issues}
  # @return [Array(Integer, Integer), nil] build order, e.g. [2, 1] for "[C2-01] ..."
  def build_order(issue)
    m = TITLE_RE.match(issue["title"])
    m && [m[1].to_i, m[2].to_i]
  end

  # @param issue [Hash] an issue with a build order
  # @return [String] e.g. "C2-01"
  def label(issue)
    format("C%d-%02d", *build_order(issue))
  end

  # @param issue [Hash] an issue with a build order
  # @return [String] branch name, at most 40 characters, e.g. "c2-01-scoring-rules-json"
  def branch_name(issue)
    words = TITLE_RE.match(issue["title"])[3].downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-+|-+\z/, "")
    "#{label(issue).downcase}-#{words}"[0, 40].sub(/-+\z/, "")
  end

  # @param issue [Hash] an issue
  # @return [String] the model a session should run
  def model_for(issue)
    issue["labels"].include?(DESIGN_LABEL) ? MODEL_DESIGN : MODEL_DEFAULT
  end

  # Blockers listed under "## Blocked by" in the body, ignoring HTML comments.
  #
  # @param issue [Hash] an issue
  # @return [Array<String>] "owner/repo#N" references
  def body_blockers(issue)
    body = (issue["body"] || "").gsub(/<!--.*?-->/m, "").delete("\r")
    section = body[/^##\s*Blocked by[^\n]*$(.*?)(?=^##\s|\z)/m, 1] || ""
    section.scan(%r{([\w.-]+/[\w.-]+)?#(\d+)}).map { |repo, n| "#{repo || REPO}##{n}" }.uniq
  end

  # @param issue [Hash] an issue
  # @param blockers [Hash{String => String}] "owner/repo#N" => state
  # @param status [String, nil] its status on the board
  # @param pr_issues [Array<Integer>] issues an open PR closes
  # @param branches [Array<String>] existing branch names
  # @return [String, nil] why the issue isn't ready, or nil when it is
  def skip_reason(issue, blockers:, status:, pr_issues:, branches:)
    open = blockers.reject { |_ref, state| state == "closed" }.keys
    prefix = "#{label(issue).downcase}-"
    if !TRUSTED_ASSOCIATIONS.include?(issue["association"]) then "opened by #{issue["author"]}, who has no role on the repo"
    elsif !open.empty? then "blocked by #{open.map { |r| r.sub("#{REPO}#", "#") }.join(", ")}"
    elsif status && status != "Todo" then "status is #{status}"
    elsif pr_issues.include?(issue["number"]) then "has an open PR"
    elsif branches.any? { |b| b.split("/").last.start_with?(prefix) } then "branch #{prefix}* exists"
    end
  end

  # @return [Array<Hash>] every open issue with a build order, in order, as
  #   {issue:, reason:}; a nil reason means ready
  def classify
    issues = all_issues.select { |i| build_order(i) }.sort_by { |i| build_order(i) }
    board = board_statuses
    prs = issues_with_open_prs
    branches = existing_branches
    issues.map do |issue|
      {issue: issue, reason: skip_reason(issue, blockers: blockers(issue), status: board[issue["number"]],
        pr_issues: prs, branches: branches)}
    end
  end

  # GitHub's own "blocked by" links plus the ones in the body. Any `gh` failure aborts, so an
  # unreadable blocker never counts as closed.
  def blockers(issue)
    found = gh_lines("api", "repos/#{REPO}/issues/#{issue["number"]}/dependencies/blocked_by", "--paginate",
      "--jq", '.[] | [(.repository_url | split("/") | .[-2:] | join("/")) + "#" + (.number | tostring), .state]').to_h
    (body_blockers(issue) - found.keys).each do |ref|
      repo, n = ref.split("#")
      found[ref] = run("gh", "api", "repos/#{repo}/issues/#{n}", "--jq", ".state").strip
    end
    found
  end

  def all_issues
    gh_lines("api", "repos/#{REPO}/issues?state=open&per_page=100", "--paginate", "--jq",
      ".[] | select(.pull_request | not) | {number, title, body, labels: [.labels[].name], " \
      "author: .user.login, association: .author_association}")
  end

  def board_statuses
    gh_lines("project", "item-list", PROJECT, "--owner", REPO.split("/").first, "--format", "json", "--limit", "1000",
      "--jq", %(.items[] | select(.content.repository == "#{REPO}") | [.content.number, .status])).to_h
  end

  def issues_with_open_prs
    gh_lines("pr", "list", "-R", REPO, "--state", "open", "--limit", "200", "--json", "body", "--jq", ".[] | {body}")
      .flat_map { |h| h["body"].to_s.scan(/\b(?:close[sd]?|fix(?:e[sd])?|resolve[sd]?)\s+#(\d+)/i) }
      .flatten.map(&:to_i)
  end

  def existing_branches
    remote = run("git", "ls-remote", "--heads", "origin").scan(%r{refs/heads/(\S+)}).flatten
    remote + run("git", "branch", "--format=%(refname:short)").split("\n")
  end

  def gh_lines(*args)
    run("gh", *args).each_line.map { |l| JSON.parse(l) }
  end

  def run(*cmd)
    out, err, status = Open3.capture3(*cmd)
    return out if status.success?

    abort "error: `#{cmd.first(3).join(" ")} ...` failed:\n#{err.strip}"
  end
end
