class LlmService
  class Error < StandardError; end
  class RateLimitError < Error; end
  class TimeoutError < Error; end
  class ParseError < Error; end

  MAX_COMPLETION_TOKENS = ENV.fetch("LLM_MAX_COMPLETION_TOKENS", 16_000).to_i

  # ── Prompts ──────────────────────────────────────────────────

  CASE_EVALUATION_PROMPT = <<~PROMPT
    You are a casework rules engine. Given a case's current state and
    the rules for this case type, determine what operations should be applied
    to advance the case.

    Return ONLY a JSON array of operations. Each operation must be one of:
    - { "op": "update", "model": "Case", "id": <case_id>, "attrs": { "status": "ready_for_decision" } }
    - { "op": "create", "model": "Action", "attrs": { "case_id": <case_id>, "title": "...", "action_type": "...", "status": "pending" } }
    - { "op": "create", "model": "CaseNote", "attrs": { "case_id": <case_id>, "content": "...", "note_type": "system" } }
    - { "op": "update", "model": "Evidence", "id": <evidence_id>, "attrs": { "status": "accepted" } }

    Only use these models: Case, Evidence, Action, CaseNote, Correspondence, EvidenceRequest, EvidenceRequestItem
    Only use enum values that exist in the schema.
    Only return operations that are justified by the rules below.

    Valid Case statuses: submitted, assigned, in_review, awaiting_evidence, ready_for_decision, decided_approved, decided_refused, withdrawn
    Valid Evidence statuses: not_received, received, under_review, accepted, rejected
    Valid Action types: chase_evidence, review_documents, make_decision, send_correspondence, escalate, schedule_interview
    Valid Action statuses: pending, in_progress, completed, blocked, cancelled
    Valid CaseNote types: manual, system, decision, evidence

    If no operations are needed (the case is already in the correct state), return an empty array: []
    Return ONLY valid JSON — no markdown fences, no explanation text.
  PROMPT

  LINK_RELEVANCE_PROMPT = <<~PROMPT
    You are helping build a casework system. Given a page about a government process and a list of links found on that page, identify which links would contain ADDITIONAL useful information for understanding:
    - Evidence/document requirements
    - Eligibility criteria
    - Decision-making process
    - Timelines/SLAs
    - Application steps

    Return a JSON array of objects: [{"url": "...", "reason": "why this link is useful"}]
    Maximum 5 links. Only include links that would add NEW information not already in the main page.
    Return ONLY valid JSON, no markdown fences.
  PROMPT

  ANALYSIS_PROMPT = <<~PROMPT
    You are an expert government process analyst. Given text from one or more pages describing a government or public sector process, produce a thorough analysis.

    Return a JSON object:
    {
      "name": "Short case type name",
      "description": "2-3 sentence description of the full process",
      "applicant_type": "Who applies",
      "caseworker_type": "Who reviews/decides",
      "evidence_requirements": [
        { "name": "Document/evidence name", "required": "mandatory|conditional|optional", "source": "Who provides", "condition": "When needed (if conditional)", "verification": "How to check it" }
      ],
      "eligibility_criteria": [
        { "criterion": "Check description", "type": "pass_fail|subjective|conditional", "fail_action": "refuse|request_more|escalate" }
      ],
      "decision_logic": [
        { "step": 1, "check": "Description", "yes": "proceed|approve", "no": "refuse|request_evidence|escalate" }
      ],
      "possible_outcomes": ["Approved", "Refused", ...],
      "typical_timeline_days": 14,
      "sla_source": "Where the SLA comes from",
      "communication_steps": [
        { "stage": "When", "channel": "email|letter|portal|phone", "content": "What", "template_needed": true|false }
      ],
      "edge_cases": ["Unusual scenarios the system should handle"],
      "confidence_scores": {
        "name": 0.9, "evidence": 0.5, "eligibility": 0.7, "decision_logic": 0.6, "timeline": 0.5, "communication": 0.4
      },
      "clarifying_questions": [
        {
          "question": "Specific question",
          "element": "Which part this clarifies",
          "options": ["Option A", "Option B", "Option C", "Other"],
          "why": "Why this matters",
          "impact": "What changes based on the answer"
        }
      ]
    }

    Rules:
    - Be thorough — extract EVERYTHING you can from the source text
    - Only ask clarifying_questions for elements with confidence < 0.7
    - Questions should be specific and actionable, not generic
    - Include edge cases you can infer (appeals, reapplication, expiry)
    - Decision logic should be a sequential checklist, not a tree
    - Return ONLY valid JSON
  PROMPT

  ENRICHMENT_PROMPT = <<~PROMPT
    You are an expert government process analyst. You previously analysed a process and asked clarifying questions. The admin has now answered them.

    Given:
    1. Your original analysis
    2. The questions and answers

    Produce an UPDATED analysis with the same JSON structure, incorporating the answers. Raise confidence scores where answers resolved ambiguity. Remove answered questions from clarifying_questions. Add any NEW questions that arise from the answers (if any).

    Return ONLY valid JSON with the same structure as the original analysis.
  PROMPT

  GENERATION_PROMPT = <<~PROMPT
    You are an expert government service designer. Given a thorough analysis of a government process, generate a complete case type configuration.

    Return a JSON object:
    {
      "name": "Case type name",
      "slug": "snake_case_slug",
      "description": "Description",
      "organisation": "Organisation name",
      "default_sla_days": 14,
      "decision_tree_md": "See format below",
      "state_transitions_md": "See format below",
      "evidence_requirements_md": "See format below",
      "correspondence_templates_md": "See format below",
      "risk_scoring_md": "See format below"
    }

    DECISION TREE FORMAT — use ASCII tree with box-drawing characters:
    ```
    START
    │
    ├─ Is [criterion]?
    │   ├─ NO → REFUSE (reason) / REQUEST evidence
    │   └─ YES ↓
    │
    ├─ Is [next criterion]?
    │   ├─ NO → REFUSE / ESCALATE
    │   └─ YES ↓
    │
    └─ APPROVE
        Outcome: [what happens]
        Conditions: [any conditions on approval]
    ```

    STATE TRANSITIONS — markdown table:
    | Current State | Trigger | Next State | Action | Auto? |
    |---|---|---|---|---|

    EVIDENCE REQUIREMENTS — markdown table:
    | Evidence | Required? | Source | Verification | Deadline |
    |---|---|---|---|---|

    CORRESPONDENCE TEMPLATES — markdown with {{ variables }}, formal gov tone:
    ## [Stage name]
    Dear {{ applicant_name }},
    ...
    Include: acknowledgement, evidence request, approval, refusal templates.

    RISK SCORING — specific numeric rules:
    ## Risk Score Calculation
    - SLA ≤ 0 days remaining: +40
    - SLA ≤ 7 days: +25
    ...

    Rules:
    - Decision tree MUST use the ASCII box-drawing format shown above
    - Be specific to THIS process, not generic
    - Correspondence must sound like real government letters — formal, clear, plain English
    - Risk scoring must use specific numbers that add up
    - Return ONLY valid JSON
  PROMPT

  SUGGESTIONS_PROMPT = <<~PROMPT
    You are an expert government service designer reviewing a case type configuration for a casework system. Analyse the configuration and suggest improvements.

    Consider:
    - GDS Service Standard compliance
    - Public Sector Equality Duty
    - Operational resilience (SLA handling, escalation paths)
    - Customer experience (self-service, reminders, clear communication)
    - Business process efficiency (automation opportunities, reducing manual steps)
    - Edge case handling (non-response, appeals, renewals)

    Return a JSON object:
    {
      "suggestions": [
        {
          "title": "Short improvement title",
          "description": "Detailed description of the improvement and how to implement it",
          "category": "One of: Business process efficiency | Compliance & fairness | Customer experience | Operational resilience | Data & reporting",
          "priority": "high | medium | low",
          "impact_description": "Quantified or qualified impact statement",
          "standard_reference": "Which standard or regulation this relates to (e.g. GDS Service Standard #3)"
        }
      ]
    }

    Rules:
    - Suggest 3-6 improvements, ordered by priority
    - Be specific to THIS case type, not generic advice
    - Each suggestion should be actionable
    - Return ONLY valid JSON
  PROMPT

  APPLY_SUGGESTIONS_PROMPT = <<~PROMPT
    You are an expert government service designer. You are updating a case type configuration to incorporate accepted improvement suggestions.

    Given:
    1. The current case type configuration (markdown sections)
    2. The accepted suggestions with any reviewer comments

    Produce UPDATED versions of the affected markdown sections, incorporating the accepted suggestions. Only return sections that have changed.

    Return a JSON object with only the updated keys:
    {
      "decision_tree_md": "updated markdown (only if changed)",
      "state_transitions_md": "updated markdown (only if changed)",
      "evidence_requirements_md": "updated markdown (only if changed)",
      "risk_scoring_md": "updated markdown (only if changed)",
      "correspondence_templates_md": "updated markdown (only if changed)",
      "summary": "Brief description of what changed"
    }

    Rules:
    - Only include keys for sections that actually changed
    - Always include the "summary" key
    - Preserve existing content — add to it, don't replace unless the suggestion requires it
    - Return ONLY valid JSON
  PROMPT

  # ── Public API ─────────────────────────────────────────────

  def initialize(model: "gpt-5.4", temperature: 0.3)
    @model = model
    @temperature = temperature
    @client = OpenAI::Client.new(
      access_token: ENV["OPENAI_API_KEY"] ||
        Rails.application.credentials.dig(:openai, :api_key) ||
        raise(Error, "OPENAI_API_KEY not set in ENV, .env, or Rails credentials")
    )
  end

  # Scrapes the provided URLs (if any), combines with the description,
  # and sends to the LLM for process analysis.
  #
  # Returns:
  #   {
  #     analysis: { ... },            # Full structured analysis hash
  #     questions: [                   # Formatted for the controller/view
  #       { id: "q1", text: "...", suggested_answers: ["A", "B", "C"] }
  #     ],
  #     metadata: { model:, tokens_used:, pages_scraped: }
  #   }
  def scrape_and_analyse!(description:, urls: [])
    total_tokens = 0
    scraped_pages = []

    # Scrape URLs if provided
    urls.each do |url|
      page = scrape_page(url)
      scraped_pages << page
    rescue => e
      Rails.logger.warn("Llm: Failed to scrape #{url}: #{e.message}")
    end

    # Build combined content
    content_parts = []
    content_parts << "## Description\n\n#{description}" if description.present?
    scraped_pages.each do |page|
      content_parts << "## Page: #{page[:title]}\n\n#{page[:text]}"
    end

    # Discover and follow relevant links from scraped pages
    if scraped_pages.any? && scraped_pages.first[:links].any?
      relevant = discover_relevant_links(scraped_pages.first, content_parts.join("\n\n"))
      total_tokens += relevant[:tokens_used]

      relevant[:links].each do |link|
        sub_page = scrape_page(link["url"])
        content_parts << "## Linked Page: #{sub_page[:title]}\n\n#{sub_page[:text]}"
        scraped_pages << sub_page
      rescue => e
        Rails.logger.warn("Llm: Failed to scrape linked page #{link['url']}: #{e.message}")
      end
    end

    combined = content_parts.join("\n\n")
    combined = combined[0, 12_000] if combined.length > 12_000

    # Analyse
    response = chat(
      ANALYSIS_PROMPT,
      "Analyse this government process:\n\n#{combined}",
      max_completion_tokens: MAX_COMPLETION_TOKENS
    )
    total_tokens += response[:tokens_used]

    analysis = parse_json(response[:content])

    {
      analysis: analysis,
      questions: build_questions_from_analysis(analysis),
      metadata: {
        model: @model,
        tokens_used: total_tokens,
        pages_scraped: scraped_pages.length
      }
    }
  end

  # Takes the original analysis and user's answers, enriches the analysis,
  # then generates the full case type configuration.
  #
  # Returns:
  #   {
  #     name:, slug:, description:, default_sla_days:,
  #     decision_tree_md:, state_transitions_md:, evidence_requirements_md:,
  #     risk_scoring_md:, correspondence_templates_md:,
  #     metadata: { model:, tokens_used: }
  #   }
  def generate_config!(analysis_json:, answers_text:)
    total_tokens = 0

    # Enrich the analysis with the user's answers
    enrichment_input = {
      original_analysis: analysis_json,
      answers: answers_text
    }

    enriched_response = chat(
      ENRICHMENT_PROMPT,
      "Update this analysis with the admin's answers:\n\n#{JSON.generate(enrichment_input)}",
      max_completion_tokens: MAX_COMPLETION_TOKENS
    )
    total_tokens += enriched_response[:tokens_used]

    enriched_analysis = parse_json(enriched_response[:content])

    # Generate full case type configuration
    gen_response = chat(
      GENERATION_PROMPT,
      "Generate a complete case type configuration:\n\n#{JSON.pretty_generate(enriched_analysis)}",
      max_completion_tokens: MAX_COMPLETION_TOKENS
    )
    total_tokens += gen_response[:tokens_used]

    config = parse_json(gen_response[:content])

    config.symbolize_keys.merge(
      metadata: { model: @model, tokens_used: total_tokens }
    )
  end

  # Analyses the current config and suggests improvements.
  #
  # config_snapshot should be a hash of the markdown sections:
  #   { decision_tree_md:, state_transitions_md:, evidence_requirements_md:,
  #     risk_scoring_md:, correspondence_templates_md:, name:, description: }
  #
  # Returns:
  #   {
  #     suggestions: [{ title:, description:, category:, priority:,
  #                      impact_description:, standard_reference: }],
  #     metadata: { model:, tokens_used: }
  #   }
  def suggest_improvements!(config_snapshot:)
    response = chat(
      SUGGESTIONS_PROMPT,
      "Review this case type configuration and suggest improvements:\n\n#{JSON.pretty_generate(config_snapshot)}",
      max_completion_tokens: MAX_COMPLETION_TOKENS
    )

    result = parse_json(response[:content])

    {
      suggestions: result["suggestions"].map(&:symbolize_keys),
      metadata: { model: @model, tokens_used: response[:tokens_used] }
    }
  end

  # Applies accepted suggestions to the config by asking the LLM to rewrite
  # affected markdown sections.
  #
  # Returns:
  #   {
  #     decision_tree_md:, state_transitions_md:, ... (only changed sections),
  #     summary: "What changed",
  #     metadata: { model:, tokens_used: }
  #   }
  def apply_suggestions!(config_snapshot:, accepted_suggestions:, comments: {})
    input = {
      current_config: config_snapshot,
      accepted_suggestions: accepted_suggestions,
      reviewer_comments: comments
    }

    response = chat(
      APPLY_SUGGESTIONS_PROMPT,
      "Apply these accepted suggestions to the case type configuration:\n\n#{JSON.pretty_generate(input)}",
      max_completion_tokens: MAX_COMPLETION_TOKENS
    )

    result = parse_json(response[:content])

    result.symbolize_keys.merge(
      metadata: { model: @model, tokens_used: response[:tokens_used] }
    )
  end

  # Evaluates a case's current state against its case type config rules
  # and returns proposed operations to advance the case.
  #
  # case_data: serialized case state (Hash)
  # rules: { decision_tree_md:, state_transitions_md:, evidence_requirements_md:, risk_scoring_md: }
  #
  # Returns:
  #   {
  #     operations: [{ "op" => "update"|"create", "model" => "...", ... }],
  #     raw_response: String,
  #     metadata: { model:, tokens_used:, elapsed: }
  #   }
  def evaluate_case!(case_data:, rules:)
    rules_text = [
      ("## Decision Tree\n#{rules[:decision_tree_md]}" if rules[:decision_tree_md].present?),
      ("## State Transitions\n#{rules[:state_transitions_md]}" if rules[:state_transitions_md].present?),
      ("## Evidence Requirements\n#{rules[:evidence_requirements_md]}" if rules[:evidence_requirements_md].present?),
      ("## Risk Scoring\n#{rules[:risk_scoring_md]}" if rules[:risk_scoring_md].present?)
    ].compact.join("\n\n")

    user_message = "RULES:\n#{rules_text}\n\nCURRENT CASE STATE:\n#{JSON.pretty_generate(case_data)}"

    response = chat(
      CASE_EVALUATION_PROMPT,
      user_message,
      max_completion_tokens: MAX_COMPLETION_TOKENS
    )

    operations = parse_json(response[:content])
    operations = [] unless operations.is_a?(Array)

    {
      operations: operations,
      raw_response: response[:content],
      metadata: { model: @model, tokens_used: response[:tokens_used], elapsed: response[:elapsed] }
    }
  end

  private

  # ── LLM Client ─────────────────────────────────────────────

  def chat(system_prompt, user_message, max_completion_tokens: MAX_COMPLETION_TOKENS)
    start = Time.now

    response = @client.chat(
      parameters: {
        model: @model,
        messages: [
          { role: "system", content: system_prompt },
          { role: "user", content: user_message }
        ],
        max_completion_tokens: max_completion_tokens,
        temperature: @temperature
      }
    )

    elapsed = (Time.now - start).round(2)
    usage = response["usage"] || {}
    content = response.dig("choices", 0, "message", "content")

    Rails.logger.info(
      "Llm: #{@model} call completed in #{elapsed}s " \
      "(#{usage['total_tokens'] || '?'} tokens)"
    )

    {
      content: content,
      tokens_used: usage["total_tokens"] || 0,
      elapsed: elapsed
    }
  rescue Faraday::TooManyRequestsError => e
    raise RateLimitError, "OpenAI rate limit exceeded: #{e.message}"
  rescue Faraday::TimeoutError, Net::OpenTimeout, Net::ReadTimeout => e
    raise TimeoutError, "OpenAI request timed out: #{e.message}"
  end

  # ── JSON Parsing ───────────────────────────────────────────

  def parse_json(text)
    cleaned = text
      .gsub(/\A\s*```(?:json)?\s*\n?/, "")  # opening fence
      .gsub(/\n?\s*```\s*\z/, "")            # closing fence
      .strip
    JSON.parse(cleaned)
  rescue JSON::ParserError => e
    raise ParseError, "Failed to parse LLM response as JSON: #{e.message}\nResponse: #{text&.first(200)}"
  end

  # ── Scraping ───────────────────────────────────────────────

  def scrape_page(url)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.open_timeout = 10
    http.read_timeout = 10

    request = Net::HTTP::Get.new(uri)
    request["User-Agent"] = "GovUK-Casework-Builder/1.0"

    response = http.request(request)
    raise Error, "HTTP #{response.code} from #{url}" unless response.is_a?(Net::HTTPSuccess)

    doc = Nokogiri::HTML(response.body)
    doc.css("nav, footer, header, script, style, noscript, .cookie-banner, #cookie-banner, .govuk-breadcrumbs, .gem-c-related-navigation").each(&:remove)

    main = doc.at_css("main") || doc.at_css("[role='main']") || doc.at_css("article") || doc.at_css("body")

    # Extract links for link discovery
    links = main.css("a[href]").filter_map do |a|
      href = a["href"]
      text = a.text.strip
      next if text.empty? || href.start_with?("#", "javascript:", "mailto:")
      resolved = URI.join(uri, href).to_s
      { text: text[0, 80], url: resolved }
    rescue URI::InvalidURIError
      nil
    end.uniq { |l| l[:url] }

    text = main.text.gsub(/\s+/, " ").gsub(/\n{3,}/, "\n\n").strip
    text = text[0, 5000] if text.length > 5000

    { text: text, links: links, title: doc.at_css("title")&.text&.strip || url }
  end

  def discover_relevant_links(main_page, existing_content)
    return { links: [], tokens_used: 0 } if main_page[:links].empty?

    links_text = main_page[:links].map { |l| "- #{l[:text]}: #{l[:url]}" }.join("\n")

    response = chat(
      LINK_RELEVANCE_PROMPT,
      "Main page content:\n#{existing_content[0, 2000]}\n\nLinks found:\n#{links_text}"
    )

    links = parse_json(response[:content])
    links = [] unless links.is_a?(Array)

    { links: links, tokens_used: response[:tokens_used] }
  rescue ParseError
    { links: [], tokens_used: 0 }
  end

  # ── Question Formatting ────────────────────────────────────

  # Transforms the analysis's clarifying_questions into the format
  # expected by the controller and views.
  def build_questions_from_analysis(analysis)
    questions = analysis["clarifying_questions"] || []

    questions.each_with_index.map do |q, i|
      {
        id: "q#{i + 1}",
        text: q["question"],
        suggested_answers: q["options"] || [],
        element: q["element"],
        why: q["why"],
        impact: q["impact"]
      }
    end
  end
end