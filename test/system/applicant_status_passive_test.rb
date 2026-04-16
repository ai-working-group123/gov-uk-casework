require "application_system_test_case"
require_relative "support/public_portal_helper"

# =============================================================================
# TC-STATUS: Applicant Status Page — Passive State (Screen 4b)
# Covers cases where no applicant action is required
# Test cases: tc-01, tc-02, tc-03, tc-06, tc-08
# =============================================================================
class ApplicantStatusPassiveTest < ApplicationSystemTestCase
  include PublicPortalHelper

  # TC-STATUS-01 (tc-02): Fresh submission — application received message
  test "fresh submission shows received status" do
    visit public_lookup_case_path(reference: "HO-T2-D9PQ")
    assert_govuk_header
    assert_text "HO-T2-D9PQ"
    assert_passive_status_panel
  end

  # TC-STATUS-02 (tc-01): Overdue case still shows passive status (no applicant action needed)
  test "overdue case where no applicant action needed shows passive awaiting evidence" do
    visit public_lookup_case_path(reference: "HO-T2-A3F9")
    assert_text "HO-T2-A3F9"
    assert_text "Awaiting evidence"
    assert_text "You do not need to do anything"
  end

  # TC-STATUS-03 (tc-06): Ready to decide case shows under review message
  test "ready to decide case shows being reviewed message" do
    visit public_lookup_case_path(reference: "HO-T4-B7KX")
    assert_text "HO-T4-B7KX"
    assert_text "being reviewed"
  end

  # TC-STATUS-04: Status page shows applicant-friendly timeline
  test "status page shows timeline with readable entries" do
    visit public_lookup_case_path(reference: "HO-T2-A3F9")
    assert_selector "ol li", minimum: 2
    assert_text "Application received"
  end

  # TC-STATUS-05: Status page shows what happens next panel
  test "status page shows what happens next section" do
    visit public_lookup_case_path(reference: "HO-T2-A3F9")
    assert_text "What happens next"
    assert_text "8 weeks"
  end

  # TC-STATUS-06: Back link navigates to lookup form
  test "back link returns to lookup form" do
    visit public_lookup_case_path(reference: "HO-T2-A3F9")
    assert_selector "a", text: /Check another application/
    click_link "Check another application"
    assert_current_path public_lookup_path
  end

  # TC-STATUS-07 (tc-16): Approved case shows positive status
  test "approved case shows success status" do
    visit public_lookup_case_path(reference: "HO-FV-W2XP")
    assert_text "HO-FV-W2XP"
    assert_text "approved"
  end

  # TC-STATUS-08 (tc-17): Refused case shows refused status without action button
  test "refused case shows refused status and no upload button" do
    visit public_lookup_case_path(reference: "HO-VS-A4NB")
    assert_text "HO-VS-A4NB"
    assert_text "unsuccessful"
    assert_no_selector "a", text: "Upload document"
  end

  # TC-STATUS-09: No internal case notes visible to applicant
  test "internal caseworker notes are not shown to applicant" do
    visit public_lookup_case_path(reference: "HO-T2-A3F9")
    assert_no_text "Sarah Chen"
    assert_no_text "sponsorship cert"
    assert_no_text "risk score"
  end

  # TC-STATUS-10: Sensitive internal data not exposed
  test "risk score and priority not visible on public portal" do
    visit public_lookup_case_path(reference: "HO-T2-A3F9")
    assert_no_text "risk_score"
    assert_no_text "High priority"
    assert_no_text "overdue"  # internal term
  end
end
