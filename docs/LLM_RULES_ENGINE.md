# LLM Rules Engine — Approach

> Use an LLM to analyse a case's current state against the case type config rules (stored as markdown), and return a set of ActiveRecord operations to advance the case.

---

## The Pipeline

### 1. Serialize case state → prompt context

Build a snapshot of the case and all its associations as structured text (JSON or YAML — LLMs parse both well):

```ruby
case_data = case_record.as_json(include: {
  evidences: { include: :policy_reference },
  actions: { include: :policy_reference },
  case_notes: {},
  evidence_requests: { include: :evidence_request_items }
})
```

Keep it flat-ish; don't send deeply nested structures.

### 2. Load the case type config rules

Pull the markdown columns from `CaseTypeConfig`:

- `decision_tree_md` — branching logic (e.g. "if evidence X is received and valid → move to ready_for_decision")
- `state_transitions_md` — valid state transitions
- `evidence_requirements_md` — what evidence is needed and when
- `risk_scoring_md` — scoring rules

These go into the prompt verbatim. The markdown-in-the-database design exists specifically for this — the config rules *are* the prompt context.

### 3. Prompt structure

```
SYSTEM: You are a casework rules engine. Given a case's current state and
the rules for this case type, determine what operations should be applied.

Return ONLY a JSON array of operations. Each operation must be one of:
- { "op": "update", "model": "Case", "id": 123, "attrs": { "status": "ready_for_decision" } }
- { "op": "create", "model": "Action", "attrs": { "case_id": 123, "title": "...", "action_type": "..." } }
- { "op": "create", "model": "CaseNote", "attrs": { ... } }
- { "op": "update", "model": "Evidence", "id": 456, "attrs": { "status": "verified" } }

Only use models: Case, Evidence, Action, CaseNote, Correspondence, EvidenceRequest, EvidenceRequestItem
Only use enum values that exist in the schema.
Only return operations that are justified by the rules below.

RULES:
{decision_tree_md}
{state_transitions_md}
{evidence_requirements_md}

CURRENT CASE STATE:
{case_data_json}
```

### 4. Parse the response → operation objects

The LLM returns a JSON array. Parse it, then map each operation to an ActiveRecord call:

```ruby
ops = JSON.parse(llm_response)

ops.each do |op|
  klass = op["model"].constantize
  case op["op"]
  when "update"
    record = klass.find(op["id"])
    record.update!(op["attrs"])
  when "create"
    klass.create!(op["attrs"])
  end
end
```

### 5. Safety layer

This is non-negotiable. The LLM must not have unconstrained write access to the database.

- **Allowlist models and attributes** — don't just `constantize` anything. Map `"Case" => Case` explicitly. Reject unknown models/attrs.
- **Allowlist operations** — only `update` and `create`. Never `destroy`.
- **Validate enum values** — check that `"status": "ready_for_decision"` is actually a valid enum value on `Case` before applying.
- **Validate state transitions** — confirm the proposed status change is legal (e.g. you can't go from `submitted` straight to `decided_approved`).
- **Scope IDs** — only allow updates to records that actually belong to this case. Don't let it update Case id 999 when you asked about case 123.
- **Wrap in a transaction** — all-or-nothing. If one op fails validation, roll everything back.
- **Audit log** — store the raw LLM response, the parsed ops, and which ones were applied/rejected (use `case_type_generation_logs`).

```ruby
ActiveRecord::Base.transaction do
  ops.each { |op| apply_validated_op!(op, case_record) }
end
```

### 6. Human-in-the-loop (optional but recommended)

Instead of auto-applying, return the proposed operations to the caseworker as a "recommendation" they confirm. Fits the existing `Action` model — create actions with `status: :pending` that the caseworker approves.

---

## Key design decisions

| Decision | Recommendation |
|---|---|
| **Output format** | JSON array of ops. Not free text. Not function calling (overkill here). |
| **Structured output** | Use the LLM provider's JSON mode / structured output if available (OpenAI `response_format`, Anthropic tool use) to guarantee valid JSON. |
| **Idempotency** | Include the case's current status in the prompt so the LLM doesn't propose transitions already made. |
| **Granularity** | One LLM call per case evaluation, not per field. Batch the thinking. |
| **Error handling** | If the LLM returns garbage, log it, surface it to the caseworker, and don't touch the DB. |
