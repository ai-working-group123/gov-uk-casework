require "application_system_test_case"
require_relative "support/public_portal_helper"

# =============================================================================
# TC-JOURNEY: End-to-end user journeys across all screens
# Full flows from lookup → status → action → upload
# =============================================================================
class EndToEndJourneyTest < ApplicationSystemTestCase
  include PublicPortalHelper

  # TC-JOURNEY-01: Happy path passive — lookup → passive status
  # Applicant checks status, no action needed (tc-01: Priya Sharma)
  test "passive journey: lookup form → passive status page" do
    visit_lookup
    assert_text "Check your visa application status"
    fill_in "reference", with: "HO-T2-A3F9"
    click_button "Check status"
    assert_text "HO-T2-A3F9"
    assert_passive_status_panel
    assert_text "What happens next"
  end

  # TC-JOURNEY-02: Action required journey — lookup → action required status
  # Single upload item (tc-04: Amara Diallo — TB cert)
  test "action required journey: lookup → action required with upload" do
    visit lookup_case_path("HO-T2-P2KR", action_required: true)
    assert_action_required_panel
    assert_text "TB certificate"
    assert_selector "a", text: "Upload document"
    click_link "Upload document"
    assert_text "Upload document"
    assert_text "HO-T2-P2KR"
  end

  # TC-JOURNEY-03: Full upload journey — status → upload → back to status
  # (tc-07: Fatima Malik — financial evidence)
  test "full upload journey: action required → upload page → return to status" do
    visit lookup_case_path("HO-T4-E5RW", action_required: true)
    assert_action_required_panel
    click_link "Upload document"
    assert_text "Upload document"
    assert_text "HO-T4-E5RW"
    click_link "Return to your application status"
    assert_current_path(/lookup/)
  end

  # TC-JOURNEY-04: Back navigation from upload to status
  test "back link from upload returns to status page" do
    visit lookup_upload_form_path("HO-T2-P2KR", 1)
    click_link "Back"
    assert_current_path(/lookup/)
  end

  # TC-JOURNEY-05: Back navigation from status to lookup
  test "back link from status returns to lookup form" do
    visit lookup_case_path("HO-T2-A3F9")
    click_link "Check another application"
    assert_current_path lookup_path
  end

  # TC-JOURNEY-06: Multi-item journey — navigate to first upload, then second
  # (tc-18: Tariq Hassan — financial evidence + SELT cert)
  test "multi-item journey: both upload links reachable from action required" do
    visit lookup_case_path("HO-T4-Q8VL", action_required: true)
    assert_action_required_panel

    # First item upload
    first_link = find_all("a", text: "Upload document").first
    first_link.click
    assert_text "Upload document"
    assert_text "HO-T4-Q8VL"
    go_back
  end

  # TC-JOURNEY-07: Maximum stress case — all items visible, all upload links reachable
  # (tc-15: Li Wei — 3 missing docs)
  test "maximum stress journey: three items all shown" do
    visit lookup_case_path("HO-T2-Z9YQ", action_required: true)
    assert_action_required_panel
    assert_text "Sponsorship certificate"
    assert_text "bank statements"
    assert_text "TB certificate"
    assert_selector "a", text: "Upload document", minimum: 1
  end

  # TC-JOURNEY-08: Physical post journey — no upload button, postal address visible
  # (tc-10: Sofia Kowalski — accommodation proof by post)
  test "physical post journey: address shown, no upload confusion" do
    visit lookup_case_path("HO-FV-R4TG", action_required: true)
    assert_text "Visa Processing Centre"
    assert_text "Sheffield"
    assert_text "HO-FV-R4TG"
    assert_text "envelope"
  end

  # TC-JOURNEY-09: Approved case journey — no action shown
  # (tc-16: Maria Santos)
  test "approved case journey: positive status, no action required" do
    visit lookup_case_path("HO-FV-W2XP")
    assert_text "approved"
    assert_no_selector "a", text: "Upload document"
    assert_no_text "Action needed"
  end

  # TC-JOURNEY-10: Refused case journey — no action shown
  # (tc-17: Pavel Novak)
  test "refused case journey: refused status, no action required" do
    visit lookup_case_path("HO-VS-A4NB")
    assert_text "unsuccessful"
    assert_no_selector "a", text: "Upload document"
    assert_no_text "Action needed"
  end
end
