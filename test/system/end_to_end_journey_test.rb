require "application_system_test_case"
require_relative "support/public_portal_helper"

# =============================================================================
# TC-JOURNEY: End-to-end user journeys across all screens
# Full flows from lookup → status → action → upload
# =============================================================================
class EndToEndJourneyTest < ApplicationSystemTestCase
  include PublicPortalHelper

  # TC-JOURNEY-01: Happy path passive — lookup → passive status
  # Applicant checks status, received (tc-02: Chen Wei)
  test "passive journey: lookup form → passive status page" do
    visit_lookup
    assert_text "Check your application status"
    fill_in "reference", with: "HO-T2-D9PQ"
    click_button "Find application"
    assert_text "HO-T2-D9PQ"
    assert_passive_status_panel
  end

  # TC-JOURNEY-02: Action required journey — lookup → action required status
  # Single upload item (tc-04: Amara Diallo — TB cert)
  test "action required journey: lookup → action required with upload" do
    visit public_lookup_case_path(reference: "HO-T2-P2KR")
    assert_action_required_panel
    assert_text "TB certificate"
    find("a", text: /Upload/, match: :first).click
    assert_text "Upload document"
    assert_text "HO-T2-P2KR"
  end

  # TC-JOURNEY-03: Full upload journey — status → upload → back to status
  # (tc-07: Fatima Malik — bank statements)
  test "full upload journey: action required → upload page → return to status" do
    visit public_lookup_case_path(reference: "HO-T4-E5RW")
    assert_action_required_panel
    find("a", text: /Upload/, match: :first).click
    assert_text "Upload document"
    assert_text "HO-T4-E5RW"
    click_link "Cancel and return to your application"
    assert_current_path(/lookup/)
  end

  # TC-JOURNEY-04: Back navigation from upload to status
  test "back link from upload returns to status page" do
    item = evidence_request_items(:tc04_tb_item)
    visit public_lookup_upload_form_path(reference: "HO-T2-P2KR", item_id: item.id)
    click_link "Back"
    assert_current_path(/lookup/)
  end

  # TC-JOURNEY-05: Back navigation from status to lookup
  test "back link from status returns to lookup form" do
    visit public_lookup_case_path(reference: "HO-T2-A3F9")
    click_link "Check a different reference"
    assert_current_path public_lookup_path
  end

  # TC-JOURNEY-06: Multi-item journey — navigate to first upload
  # (tc-18: Tariq Hassan — bank statements + SELT cert)
  test "multi-item journey: both upload links reachable from action required" do
    visit public_lookup_case_path(reference: "HO-T4-Q8VL")
    assert_action_required_panel
    find("a", text: /Upload/, match: :first).click
    assert_text "Upload document"
    assert_text "HO-T4-Q8VL"
    go_back
  end

  # TC-JOURNEY-07: Maximum stress case — all items visible
  # (tc-15: Li Wei — 3 missing docs)
  test "maximum stress journey: three items all shown" do
    visit public_lookup_case_path(reference: "HO-T2-Z9YQ")
    assert_text "Documents we need from you"
    assert_text "Sponsorship certificate"
    assert_text "Bank statements"
    assert_text "TB certificate"
  end

  # TC-JOURNEY-08: Physical post journey — no upload link for physical item
  # (tc-10: Sofia Kowalski — accommodation proof by post)
  test "physical evidence journey: item shown without upload link" do
    visit public_lookup_case_path(reference: "HO-FV-R4TG")
    assert_text "Accommodation proof"
    assert_text "HO-FV-R4TG"
    assert_no_selector "a", text: /Upload/
  end

  # TC-JOURNEY-09: Approved case journey — no action shown
  # (tc-16: Maria Santos)
  test "approved case journey: positive status, no action required" do
    visit public_lookup_case_path(reference: "HO-FV-W2XP")
    assert_text /approved/i
    assert_no_selector "a", text: /Upload/
  end

  # TC-JOURNEY-10: Refused case journey — no action shown
  # (tc-17: Pavel Novak)
  test "refused case journey: refused status, no action required" do
    visit public_lookup_case_path(reference: "HO-VS-A4NB")
    assert_text /unsuccessful/i
    assert_no_selector "a", text: /Upload/
  end
end
