# Data Model — Challenge 3: Supporting Casework Decisions

## Entity Relationship Diagram (Text)

```
┌──────────────┐       ┌──────────────┐       ┌──────────────────┐
│    Team      │──1:N──│  Caseworker   │──1:N──│      Case        │
└──────────────┘       └──────────────┘       └──────────────────┘
                                                │        │        │
                                                │        │        │
                                          1:N   │        │  1:N   │ 1:N
                                                │        │        │
                                    ┌───────────┘        │        └──────────────┐
                                    │                    │                       │
                              ┌─────┴──────┐    ┌───────┴────────┐  ┌───────────┴──────┐
                              │  Evidence   │◄──│   CaseNote     │  │ EvidenceRequest  │
                              └─────┬──────┘   └────────────────┘  └───────┬──────────┘
                                    │ N:1                                  │ 1:N
                              ┌─────▼────────────┐              ┌──────────▼──────────┐
                              │  PolicyReference  │◄── N:1 ──┐  │ EvidenceRequestItem │
                              └──────────────────┘           │  └──────────┬──────────┘
                                    ▲ N:1                    │             │ N:1
                              ┌─────┴──────┐                 │             │
                              │   Action   │──N:1──Case      │             ▼
                              └─────┬──────┘                 │       Evidence (links
                                    │ 1:N                    │        requested item
                              ┌─────▼──────────┐             │        to evidence row)
                              │  Correspondence│─────────────┘
                              └────────────────┘  (cites policy)
```

**Key relationships:**
- `Evidence` → `PolicyReference`: "This document is required because of [this rule]"
- `Action` → `PolicyReference`: "This next step is driven by [this policy criterion]"
- `Correspondence` → `PolicyReference`: "Dear applicant, we need X because [link to guidance]"
- `PolicyReference` has a hierarchy: a top-level policy (e.g. "Appendix Skilled Worker") contains multiple criteria, each with its own GOV.UK URL
- `EvidenceRequest` → `Case`: "This batch of requests belongs to this case"
- `EvidenceRequestItem` → `Evidence`: "This request item corresponds to this evidence row"
- `EvidenceRequestItem` → `PolicyReference`: "We're asking for this because of [this rule]"

---

## ActiveRecord Models & Migrations

### Migrations

```ruby
# db/migrate/001_create_teams.rb
class CreateTeams < ActiveRecord::Migration[8.0]
  def change
    create_table :teams do |t|
      t.string :name, null: false
      t.string :leader_id
      t.timestamps
    end
  end
end

# db/migrate/002_create_caseworkers.rb
class CreateCaseworkers < ActiveRecord::Migration[8.0]
  def change
    create_table :caseworkers do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.integer :role, default: 0 # enum: caseworker, senior_caseworker, team_leader
      t.references :team, null: false, foreign_key: true
      t.integer :capacity, default: 15
      t.timestamps
    end
    add_index :caseworkers, :email, unique: true
  end
end

# db/migrate/003_create_cases.rb
class CreateCases < ActiveRecord::Migration[8.0]
  def change
    create_table :cases do |t|
      t.string :reference, null: false
      t.string :applicant_name, null: false
      t.string :applicant_email
      t.string :nationality
      t.integer :case_type, null: false
      t.integer :status, default: 0
      t.integer :priority, default: 1
      t.integer :risk_score, default: 0
      t.references :assigned_to, foreign_key: { to_table: :caseworkers }
      t.datetime :submitted_at, default: -> { "CURRENT_TIMESTAMP" }
      t.datetime :assigned_at
      t.datetime :sla_deadline, null: false
      t.datetime :decided_at
      t.timestamps
    end
    add_index :cases, :reference, unique: true
  end
end

# db/migrate/004_create_evidences.rb
class CreateEvidences < ActiveRecord::Migration[8.0]
  def change
    create_table :evidences do |t|
      t.references :case, null: false, foreign_key: true
      t.integer :evidence_type, null: false
      t.integer :status, default: 0
      t.datetime :received_at
      t.datetime :reviewed_at
      t.text :notes
      t.datetime :required_by
      t.references :policy_reference, foreign_key: true
      t.timestamps
    end
  end
end

# db/migrate/005_create_case_notes.rb
class CreateCaseNotes < ActiveRecord::Migration[8.0]
  def change
    create_table :case_notes do |t|
      t.references :case, null: false, foreign_key: true
      t.references :caseworker, foreign_key: true
      t.text :content, null: false
      t.integer :note_type, default: 0
      t.boolean :visible_to_applicant, default: false
      t.string :applicant_message
      t.timestamps
    end
  end
end

# db/migrate/006_create_actions.rb
class CreateActions < ActiveRecord::Migration[8.0]
  def change
    create_table :actions do |t|
      t.references :case, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.integer :action_type, null: false
      t.integer :status, default: 0
      t.datetime :due_date
      t.datetime :completed_at
      t.string :blocked_by
      t.references :policy_reference, foreign_key: true
      t.text :caseworker_guidance
      t.timestamps
    end
  end
end

# db/migrate/007_create_correspondences.rb
class CreateCorrespondences < ActiveRecord::Migration[8.0]
  def change
    create_table :correspondences do |t|
      t.references :action, null: false, foreign_key: true
      t.integer :channel, default: 0
      t.integer :direction, default: 0
      t.string :subject, null: false
      t.text :body, null: false
      t.references :policy_reference, foreign_key: true
      t.text :policy_explanation
      t.string :guidance_url
      t.datetime :sent_at
      t.timestamps
    end
  end
end

# db/migrate/008_create_policy_references.rb
class CreatePolicyReferences < ActiveRecord::Migration[8.0]
  def change
    create_table :policy_references do |t|
      t.string :code, null: false
      t.string :parent_code
      t.string :title, null: false
      t.string :policy_area, null: false
      t.string :case_types, null: false
      t.text :summary, null: false
      t.text :criteria, null: false
      t.string :govuk_url
      t.string :legislation_url
      t.string :internal_guidance_url
      t.text :applicant_summary
      t.string :applicant_url
      t.timestamps
    end
    add_index :policy_references, :code, unique: true
  end
end

# db/migrate/009_create_evidence_requests.rb
class CreateEvidenceRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :evidence_requests do |t|
      t.references :case, null: false, foreign_key: true
      t.references :requested_by, null: false, foreign_key: { to_table: :caseworkers }
      t.integer :status, default: 0          # enum: draft, sent, partially_fulfilled, fulfilled, expired
      t.datetime :deadline, null: false
      t.integer :notify_via, default: 0      # bitmask: email=1, portal=2, sms=4
      t.text :cover_message                  # auto-generated, caseworker-editable
      t.datetime :sent_at
      t.datetime :reminder_sent_at
      t.timestamps
    end
  end
end

# db/migrate/010_create_evidence_request_items.rb
class CreateEvidenceRequestItems < ActiveRecord::Migration[8.0]
  def change
    create_table :evidence_request_items do |t|
      t.references :evidence_request, null: false, foreign_key: true
      t.references :evidence, null: false, foreign_key: true
      t.references :policy_reference, foreign_key: true
      t.integer :submission_method, null: false  # enum: digital, physical, either
      t.text :reason, null: false                # plain-English explanation for applicant
      t.integer :status, default: 0              # enum: pending, received, accepted, rejected
      t.string :upload_content_type              # MIME type of uploaded file (if digital)
      t.integer :upload_file_size                # bytes
      t.datetime :received_at
      t.text :applicant_note                     # optional note from applicant on upload
      t.timestamps
    end
  end
end
```

### Models

```ruby
# app/models/team.rb
class Team < ApplicationRecord
  has_many :caseworkers
end

# app/models/caseworker.rb
class Caseworker < ApplicationRecord
  belongs_to :team
  has_many :cases, foreign_key: :assigned_to_id
  has_many :case_notes
  enum :role, { caseworker: 0, senior_caseworker: 1, team_leader: 2 }
end

# app/models/case.rb (use `self.table_name = "cases"` — Rails handles this)
class Case < ApplicationRecord
  belongs_to :assigned_to, class_name: "Caseworker", optional: true
  has_many :evidences
  has_many :case_notes
  has_many :actions
  has_many :evidence_requests

  enum :case_type, { tier2_work: 0, tier4_student: 1, family_visa: 2, settlement: 3, visitor: 4 }
  enum :status, { submitted: 0, assigned: 1, in_review: 2, awaiting_evidence: 3,
                  ready_for_decision: 4, decided_approved: 5, decided_refused: 6, withdrawn: 7 }
  enum :priority, { low: 0, medium: 1, high: 2, urgent: 3 }

  # Human-friendly reference number: HO-{TYPE}-{ALPHANUMERIC}
  # Format: HO-T2-A3F9, HO-FV-B1C2, etc.
  # - HO = Home Office prefix
  # - TYPE = 2-char case type code (see CASE_TYPE_CODES)
  # - ALPHANUMERIC = 4-char random uppercase alphanumeric (excluding 0/O/I/1 for readability)
  CASE_TYPE_CODES = {
    "tier2_work"   => "T2",
    "tier4_student" => "T4",
    "family_visa"  => "FV",
    "settlement"   => "ST",
    "visitor"      => "VS"
  }.freeze

  REFERENCE_CHARS = ("A".."Z").to_a - %w[I O] + ("2".."9").to_a  # excludes 0/O/I/1

  before_validation :generate_reference, on: :create

  scope :overdue, -> { where("sla_deadline < ?", Time.current).where.not(status: %i[decided_approved decided_refused withdrawn]) }
  scope :approaching_sla, -> { where(sla_deadline: Time.current..7.days.from_now).where.not(status: %i[decided_approved decided_refused withdrawn]) }

  private

  def generate_reference
    return if reference.present?

    type_code = CASE_TYPE_CODES[case_type] || "XX"
    loop do
      suffix = Array.new(4) { REFERENCE_CHARS.sample }.join
      self.reference = "HO-#{type_code}-#{suffix}"
      break unless Case.exists?(reference: reference)
    end
  end
end

# app/models/evidence.rb
class Evidence < ApplicationRecord
  belongs_to :case
  belongs_to :policy_reference, optional: true
  enum :evidence_type, { passport: 0, english_language: 1, tb_certificate: 2, bank_statements: 3,
                         sponsorship_certificate: 4, biometrics: 5, employer_letter: 6,
                         accommodation_proof: 7, relationship_evidence: 8, police_clearance: 9 }
  enum :status, { not_received: 0, received: 1, under_review: 2, accepted: 3, rejected: 4 }
end

# app/models/case_note.rb
class CaseNote < ApplicationRecord
  belongs_to :case
  belongs_to :caseworker, optional: true
  enum :note_type, { manual: 0, system: 1, decision: 2, evidence: 3 }
end

# app/models/action.rb
class Action < ApplicationRecord
  belongs_to :case
  belongs_to :policy_reference, optional: true
  has_many :correspondences
  enum :action_type, { chase_evidence: 0, review_documents: 1, make_decision: 2,
                       send_correspondence: 3, escalate: 4, schedule_interview: 5 }
  enum :status, { pending: 0, in_progress: 1, completed: 2, blocked: 3, cancelled: 4 }
end

# app/models/correspondence.rb
class Correspondence < ApplicationRecord
  belongs_to :action
  belongs_to :policy_reference, optional: true
  enum :channel, { letter: 0, email: 1, portal: 2, sms: 3 }
  enum :direction, { outbound: 0, inbound: 1 }
end

# app/models/policy_reference.rb
class PolicyReference < ApplicationRecord
  has_many :evidences
  has_many :actions
  has_many :correspondences
  has_many :evidence_request_items
end

# app/models/evidence_request.rb
class EvidenceRequest < ApplicationRecord
  belongs_to :case
  belongs_to :requested_by, class_name: "Caseworker"
  has_many :evidence_request_items, dependent: :destroy
  accepts_nested_attributes_for :evidence_request_items, allow_destroy: true

  enum :status, { draft: 0, sent: 1, partially_fulfilled: 2, fulfilled: 3, expired: 4 }

  NOTIFY_EMAIL  = 1
  NOTIFY_PORTAL = 2
  NOTIFY_SMS    = 4

  def notify_email?  = notify_via & NOTIFY_EMAIL  > 0
  def notify_portal? = notify_via & NOTIFY_PORTAL > 0
  def notify_sms?    = notify_via & NOTIFY_SMS    > 0

  def all_items_received?
    evidence_request_items.all? { |item| item.received? || item.accepted? }
  end
end

# app/models/evidence_request_item.rb
class EvidenceRequestItem < ApplicationRecord
  belongs_to :evidence_request
  belongs_to :evidence
  belongs_to :policy_reference, optional: true

  enum :submission_method, { digital: 0, physical: 1, either: 2 }
  enum :status, { pending: 0, received: 1, accepted: 2, rejected: 3 }

  def allows_upload?
    digital? || either?
  end

  def requires_post?
    physical? || either?
  end
end
```

---

## Routes & Controllers

```ruby
# config/routes.rb
Rails.application.routes.draw do
  # Caseworker views
  resources :cases, only: [:index, :show, :update] do
    resources :notes, only: [:create], controller: "case_notes"
    resources :actions, only: [:index, :update] do
      post :correspond, on: :member
    end
    resources :evidences, only: [:index, :update]
    resources :evidence_requests, only: [:new, :create, :show, :update] do
      post :send_request, on: :member   # sends notification to applicant
      post :send_reminder, on: :member  # re-sends reminder
    end
    get :timeline, on: :member
  end

  # Dashboard views
  namespace :dashboards do
    get "caseworker/:id", action: :caseworker, as: :caseworker
    get "team/:id",       action: :team,       as: :team
    get "overview",       action: :overview
  end

  # Public applicant portal
  get  "lookup",              to: "lookup#index"
  get  "lookup/:reference",   to: "lookup#show", as: :lookup_case
  # Applicant evidence upload (accessed via portal)
  get  "lookup/:reference/evidence/:item_id",  to: "lookup#upload_form", as: :lookup_upload_form
  post "lookup/:reference/evidence/:item_id",  to: "lookup#upload",      as: :lookup_upload

  # Policy reference browsing
  resources :policy_references, only: [:index, :show], param: :code
end
```

### Generated Routes

```
GET    /cases                        → cases#index       (caseworker dashboard, filterable)
GET    /cases/:id                    → cases#show        (full case detail)
PATCH  /cases/:id                    → cases#update      (update status/priority)
GET    /cases/:id/timeline           → cases#timeline    (applicant-visible notes)

GET    /cases/:case_id/evidences     → evidences#index   (evidence list with policy_reference)
PATCH  /cases/:case_id/evidences/:id → evidences#update  (mark received, etc.)

POST   /cases/:case_id/notes         → case_notes#create (add a case note)
GET    /cases/:case_id/actions       → actions#index     (next actions + policy + guidance)
PATCH  /cases/:case_id/actions/:id   → actions#update    (update action status)
POST   /cases/:case_id/actions/:id/correspond → actions#correspond (generate correspondence)

GET    /dashboards/caseworker/:id    → dashboards#caseworker
GET    /dashboards/team/:id          → dashboards#team
GET    /dashboards/overview          → dashboards#overview

GET    /cases/:case_id/evidence_requests/new        → evidence_requests#new   (request evidence form)
POST   /cases/:case_id/evidence_requests              → evidence_requests#create (save draft)
GET    /cases/:case_id/evidence_requests/:id           → evidence_requests#show  (view request)
PATCH  /cases/:case_id/evidence_requests/:id           → evidence_requests#update (edit draft)
POST   /cases/:case_id/evidence_requests/:id/send_request  → evidence_requests#send_request
POST   /cases/:case_id/evidence_requests/:id/send_reminder → evidence_requests#send_reminder

GET    /lookup                       → lookup#index      (reference number search form)
GET    /lookup/:reference            → lookup#show       (applicant status + action required)
GET    /lookup/:reference/evidence/:item_id  → lookup#upload_form (document upload page)
POST   /lookup/:reference/evidence/:item_id  → lookup#upload      (process uploaded file)

GET    /policy_references            → policy_references#index
GET    /policy_references/:code      → policy_references#show
```

### Controller Structure

```
app/controllers/
├── cases_controller.rb             # index (caseworker dashboard), show (case detail), update
├── case_notes_controller.rb        # create (nested under cases)
├── actions_controller.rb           # index, update, correspond (nested under cases)
├── evidences_controller.rb         # index, update (nested under cases)
├── evidence_requests_controller.rb # new, create, show, update, send_request, send_reminder
├── dashboards_controller.rb        # caseworker, team, overview
├── lookup_controller.rb            # index, show, upload_form, upload (applicant portal + uploads)
└── policy_references_controller.rb # index, show
```

### View Structure

```
app/views/
├── cases/
│   ├── index.html.erb              # Caseworker dashboard (morning view)
│   └── show.html.erb               # Case detail page
├── dashboards/
│   ├── caseworker.html.erb         # Individual caseworker stats
│   ├── team.html.erb               # Team leader dashboard
│   └── overview.html.erb           # High-level stats
├── evidence_requests/
│   ├── new.html.erb                # Request evidence form (Screen 5)
│   ├── show.html.erb               # View sent/draft request
│   └── _item_fields.html.erb       # Nested fields partial for each item
├── lookup/
│   ├── index.html.erb              # Reference number search form (GOV.UK style)
│   ├── show.html.erb               # Applicant status + action required (Screen 6)
│   └── upload_form.html.erb        # Document upload page (Screen 7)
├── shared/
│   ├── _evidence_checklist.html.erb # Updated to show request status (Screen 8)
│   ├── _case_timeline.html.erb
│   ├── _next_actions.html.erb
│   ├── _policy_sidebar.html.erb
│   └── _stats_cards.html.erb
└── layouts/
    ├── application.html.erb        # Internal staff layout
    └── public.html.erb             # GOV.UK-style layout for applicant portal
```

Also see ./SEED_DATA_STRATEGY.md for how to generate synthetic data that tells a compelling story through the demo.