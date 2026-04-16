require "application_system_test_case"
require_relative "support/public_portal_helper"

# =============================================================================
# TC-STATUS: Applicant Status Page — Passive State (Screen 4b)
# Covers cases where no applicant action is required
# Test cases: tc-01, tc-02, tc-06, tc-16, tc-17
# =============================================================================
class ApplicantStatusPassiveTest < ApplicationSystemTestCase
  include PublicPortalHelper

  # TC-STATUS-01 (tc-02): Fresh submission — application received message
  test "fresh submission shows received status" do
    visit public_lookup_case_path(reference: "HO-T2-D9PQ")
    assert_govuk_header
    assert_text "HO-T2-D9PQ"
    assert_passive_status_panel
    assert_text /received/i
  end

  # TC-STATUS-02 (tc-01): Awaiting evidence case shows status tag
  test "awaiting evidence case shows action required status" do
    visit public_lookup_case_path(reference: "HO-T2-A3F9")
    assert_text "HO-T2-A3F9"
    assert_text /action required/i
  end

  # TC-STATUS-03 (tc-06): Ready to decide case shows decision pending
  test "ready to decide case shows decision pending message" do
    visit public_lookup_case_path(reference: "HO-T4-B7KX")
    assert_text "HO-T4-B7KX"
    assert_text /decision pending/i
  end

  # TC-STATUS-04: Status page shows applicant name and reference
  test "status page shows applicant name and reference" do
    visit public_lookup_case_path(reference: "HO-T2-A3F9")
    assert_text "HO-T2-A3F9"
    assert_text "Priya Sharma"
  end

  # TC-STATUS-05 (tc-16): Approved case shows what happens next
  test "approved case shows what happens next section" do
    visit public_lookup_case_path(reference: "HO-FV-W2XP")
    assert_text "What happens next"
    assert_text "approved"
  end

  # TC-STATUS-06: Back link navigates to lookup form
  test "back link returns to lookup form" do
    visit public_lookup_case_path(reference: "HO-T2-A3F9")
    click_link "Check a different reference"
    assert_current_path public_lookup_path
  end

  # TC-STATUS-07 (tc-16): Approved case shows positive status
  test "approved case shows success status" do
    visit public_lookup_case_path(reference: "HO-FV-W2XP")
    assert_text "HO-FV-W2XP"
    assert_text /approved/i
  end

  # TC-STATUS-08 (tc-17): Refused case shows refused status without upload link
  test "refused case shows unsuccessful status and no upload link" do
    visit public_lookup_case_path(reference: "HO-VS-A4NB")
    assert_text "HO-VS-A4NB"
    assert_text /unsuccessful/i
    assert_no_selector "a", text: /Upload/
  end

  # TC-STATUS-09: No internal case notes visible to applicant
  test "internal caseworker notes are not shown to applicant" do
    visit public_lookup_case_path(reference: "HO-T2-A3F9")
    assert_no_text "Sarah Chen"
    assert_no_text "risk score"
  end

  # TC-STATUS-10: Sensitive internal data not exposed
  test "risk score and priority not visible on public portal" do
    visit public_lookup_case_path(reference: "HO-T2-A3F9")
    assert_no_text "risk_score"
    assert_no_text "High priority"
  end
end
