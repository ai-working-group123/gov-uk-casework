require "application_system_test_case"
require_relative "support/public_portal_helper"

# =============================================================================
# TC-ACTION: Applicant Status Page — Action Required State (Screen 6)
# Covers cases where applicant must provide documents
# Test cases: tc-04, tc-07, tc-10, tc-15, tc-18
# =============================================================================
class ApplicantActionRequiredTest < ApplicationSystemTestCase
  include PublicPortalHelper

  # TC-ACTION-01 (tc-04): Single item — TB certificate, digital upload
  test "single action required item shows upload link" do
    visit public_lookup_case_path(reference: "HO-T2-P2KR")
    assert_govuk_header
    assert_action_required_panel
    assert_text "TB certificate"
    assert_selector "a", text: /Upload/
  end

  # TC-ACTION-02 (tc-04): Shows plain-English reason for document
  test "action required shows plain English reason for TB cert" do
    visit public_lookup_case_path(reference: "HO-T2-P2KR")
    assert_text "TB certificate"
    assert_text "approved clinic"
  end

  # TC-ACTION-03 (tc-07): Approaching SLA case shows action required with evidence items
  test "approaching SLA case shows action required with evidence items" do
    visit public_lookup_case_path(reference: "HO-T4-E5RW")
    assert_action_required_panel
    assert_text "Bank statements"
    assert_selector "a", text: /Upload/
  end

  # TC-ACTION-04 (tc-10): Physical post item shows document name
  test "physical post evidence item shows document name" do
    visit public_lookup_case_path(reference: "HO-FV-R4TG")
    assert_text "Accommodation proof"
    assert_text "HO-FV-R4TG"
  end

  # TC-ACTION-05 (tc-10): Physical post item shows reason text
  test "physical post item shows reason for document" do
    visit public_lookup_case_path(reference: "HO-FV-R4TG")
    assert_text "Tenancy agreement or surveyor report"
  end

  # TC-ACTION-06 (tc-18): Multiple items all shown
  test "multiple action items all displayed" do
    visit public_lookup_case_path(reference: "HO-T4-Q8VL")
    assert_action_required_panel
    assert_text "Bank statements"
    assert_text "SELT certificate"
    assert_selector "a", text: /Upload/, minimum: 2
  end

  # TC-ACTION-07 (tc-15): Maximum stress — 3 missing items
  test "maximum stress case shows all three missing items" do
    visit public_lookup_case_path(reference: "HO-T2-Z9YQ")
    assert_text "Documents we need from you"
    assert_text "Sponsorship certificate"
    assert_text "Bank statements"
    assert_text "TB certificate"
  end

  # TC-ACTION-08: Status tag shows yellow action required indicator
  test "action required state shows yellow action required tag" do
    visit public_lookup_case_path(reference: "HO-T2-P2KR")
    assert_selector ".govuk-tag--yellow", text: /action required/i
  end

  # TC-ACTION-09: Evidence item reason displayed
  test "evidence item shows reason text" do
    visit public_lookup_case_path(reference: "HO-T2-P2KR")
    assert_text "TB certificate"
    assert_text "approved clinic"
  end

  # TC-ACTION-10: Warning text about providing documents
  test "action required page shows warning about providing documents" do
    visit public_lookup_case_path(reference: "HO-T2-P2KR")
    assert_text "You need to provide"
    assert_text "before we can continue"
  end

  # TC-ACTION-11: Status page shows submitted date
  test "status page shows submitted date" do
    visit public_lookup_case_path(reference: "HO-T2-P2KR")
    assert_text "Date submitted"
    assert_text "10 January 2024"
  end

  # TC-ACTION-12 (tc-10): Physical item has no upload link
  test "physical evidence item has no upload link" do
    visit public_lookup_case_path(reference: "HO-FV-R4TG")
    assert_text "Accommodation proof"
    assert_no_selector "a", text: /Upload/
  end
end
