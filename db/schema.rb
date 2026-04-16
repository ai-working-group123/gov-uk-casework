# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_16_130000) do
  create_table "actions", force: :cascade do |t|
    t.integer "action_type", null: false
    t.string "blocked_by"
    t.integer "case_id", null: false
    t.text "caseworker_guidance"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "due_date"
    t.integer "policy_reference_id"
    t.integer "status", default: 0
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["case_id"], name: "index_actions_on_case_id"
    t.index ["policy_reference_id"], name: "index_actions_on_policy_reference_id"
  end

  create_table "case_notes", force: :cascade do |t|
    t.string "applicant_message"
    t.integer "case_id", null: false
    t.integer "caseworker_id"
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.integer "note_type", default: 0
    t.datetime "updated_at", null: false
    t.boolean "visible_to_applicant", default: false
    t.index ["case_id"], name: "index_case_notes_on_case_id"
    t.index ["caseworker_id"], name: "index_case_notes_on_caseworker_id"
  end

  create_table "case_type_configs", force: :cascade do |t|
    t.json "analysis", default: {}
    t.json "clarifying_answers", default: {}
    t.json "clarifying_questions", default: []
    t.text "correspondence_templates_md"
    t.datetime "created_at", null: false
    t.integer "created_by_id"
    t.text "decision_tree_md", null: false
    t.integer "default_sla_days"
    t.text "description"
    t.text "evidence_requirements_md"
    t.string "name", null: false
    t.string "organisation"
    t.text "risk_scoring_md"
    t.string "slug", null: false
    t.json "source_metadata", default: {}
    t.text "state_transitions_md", null: false
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_case_type_configs_on_created_by_id"
    t.index ["slug"], name: "index_case_type_configs_on_slug", unique: true
  end

  create_table "case_type_generation_logs", force: :cascade do |t|
    t.integer "case_type_config_id", null: false
    t.float "confidence_score"
    t.datetime "created_at", null: false
    t.text "input_text"
    t.string "model_used"
    t.text "output_text"
    t.integer "step", null: false
    t.string "step_name", null: false
    t.integer "tokens_used"
    t.datetime "updated_at", null: false
    t.index ["case_type_config_id"], name: "index_case_type_generation_logs_on_case_type_config_id"
  end

  create_table "case_type_suggestions", force: :cascade do |t|
    t.integer "case_type_config_id", null: false
    t.string "category"
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.text "impact_description"
    t.integer "priority", default: 1
    t.datetime "resolved_at"
    t.integer "resolved_by_id"
    t.string "standard_reference"
    t.integer "status", default: 0
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["case_type_config_id"], name: "index_case_type_suggestions_on_case_type_config_id"
    t.index ["resolved_by_id"], name: "index_case_type_suggestions_on_resolved_by_id"
  end

  create_table "cases", force: :cascade do |t|
    t.string "applicant_email"
    t.string "applicant_name", null: false
    t.datetime "assigned_at"
    t.integer "assigned_to_id"
    t.json "case_data", default: {}
    t.integer "case_type_config_id"
    t.datetime "created_at", null: false
    t.datetime "decided_at"
    t.string "nationality"
    t.integer "priority", default: 1
    t.string "reference", null: false
    t.integer "risk_score", default: 0
    t.datetime "sla_deadline", null: false
    t.integer "status", default: 0
    t.datetime "submitted_at", default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "updated_at", null: false
    t.index ["assigned_to_id"], name: "index_cases_on_assigned_to_id"
    t.index ["case_type_config_id"], name: "index_cases_on_case_type_config_id"
    t.index ["reference"], name: "index_cases_on_reference", unique: true
  end

  create_table "caseworkers", force: :cascade do |t|
    t.integer "capacity", default: 15
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.integer "role", default: 0
    t.integer "team_id", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_caseworkers_on_email", unique: true
    t.index ["team_id"], name: "index_caseworkers_on_team_id"
  end

  create_table "correspondences", force: :cascade do |t|
    t.integer "action_id", null: false
    t.text "body", null: false
    t.integer "channel", default: 0
    t.datetime "created_at", null: false
    t.integer "direction", default: 0
    t.string "guidance_url"
    t.text "policy_explanation"
    t.integer "policy_reference_id"
    t.datetime "sent_at"
    t.string "subject", null: false
    t.datetime "updated_at", null: false
    t.index ["action_id"], name: "index_correspondences_on_action_id"
    t.index ["policy_reference_id"], name: "index_correspondences_on_policy_reference_id"
  end

  create_table "evidence_request_items", force: :cascade do |t|
    t.text "applicant_note"
    t.datetime "created_at", null: false
    t.integer "evidence_id", null: false
    t.integer "evidence_request_id", null: false
    t.integer "policy_reference_id"
    t.text "reason", null: false
    t.datetime "received_at"
    t.integer "status", default: 0
    t.integer "submission_method", null: false
    t.datetime "updated_at", null: false
    t.string "upload_content_type"
    t.integer "upload_file_size"
    t.index ["evidence_id"], name: "index_evidence_request_items_on_evidence_id"
    t.index ["evidence_request_id"], name: "index_evidence_request_items_on_evidence_request_id"
    t.index ["policy_reference_id"], name: "index_evidence_request_items_on_policy_reference_id"
  end

  create_table "evidence_requests", force: :cascade do |t|
    t.integer "case_id", null: false
    t.text "cover_message"
    t.datetime "created_at", null: false
    t.datetime "deadline", null: false
    t.integer "notify_via", default: 0
    t.datetime "reminder_sent_at"
    t.integer "requested_by_id", null: false
    t.datetime "sent_at"
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.index ["case_id"], name: "index_evidence_requests_on_case_id"
    t.index ["requested_by_id"], name: "index_evidence_requests_on_requested_by_id"
  end

  create_table "evidences", force: :cascade do |t|
    t.integer "case_id", null: false
    t.datetime "created_at", null: false
    t.integer "evidence_type", null: false
    t.text "notes"
    t.integer "policy_reference_id"
    t.datetime "received_at"
    t.datetime "required_by"
    t.datetime "reviewed_at"
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.index ["case_id"], name: "index_evidences_on_case_id"
    t.index ["policy_reference_id"], name: "index_evidences_on_policy_reference_id"
  end

  create_table "policy_references", force: :cascade do |t|
    t.text "applicant_summary"
    t.string "applicant_url"
    t.string "case_types", null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.text "criteria", null: false
    t.string "govuk_url"
    t.string "internal_guidance_url"
    t.string "legislation_url"
    t.string "parent_code"
    t.string "policy_area", null: false
    t.text "summary", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_policy_references_on_code", unique: true
  end

  create_table "teams", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "leader_id"
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "actions", "cases"
  add_foreign_key "actions", "policy_references"
  add_foreign_key "case_notes", "cases"
  add_foreign_key "case_notes", "caseworkers"
  add_foreign_key "case_type_configs", "caseworkers", column: "created_by_id"
  add_foreign_key "case_type_generation_logs", "case_type_configs"
  add_foreign_key "case_type_suggestions", "case_type_configs"
  add_foreign_key "case_type_suggestions", "caseworkers", column: "resolved_by_id"
  add_foreign_key "cases", "case_type_configs"
  add_foreign_key "cases", "caseworkers", column: "assigned_to_id"
  add_foreign_key "caseworkers", "teams"
  add_foreign_key "correspondences", "actions"
  add_foreign_key "correspondences", "policy_references"
  add_foreign_key "evidence_request_items", "evidence_requests"
  add_foreign_key "evidence_request_items", "evidences"
  add_foreign_key "evidence_request_items", "policy_references"
  add_foreign_key "evidence_requests", "cases"
  add_foreign_key "evidence_requests", "caseworkers", column: "requested_by_id"
  add_foreign_key "evidences", "cases"
  add_foreign_key "evidences", "policy_references"
end
