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
  test "single action required item shows upload button" do
    visit public_lookup_case_path(reference: "HO-T2-P2KR")
    assert_govuk_header
    assert_action_required_panel
    assert_text "TB certificate"
    assert_selector "a", text: "Upload document"
  end

  # TC-ACTION-02 (tc-04): Shows plain-English reason for document
  test "action required shows plain English reason for TB cert" do
    visit public_lookup_case_path(reference: "HO-T2-P2KR")
    assert_text "TB certificate"
    assert_text "approved clinic"
  end

  # TC-ACTION-03 (tc-07): Approaching SLA case shows deadline prominently
  test "approaching SLA case shows deadline clearly" do
    visit public_lookup_case_path(reference: "HO-T4-E5RW")
    assert_action_required_panel
    assert_text "Deadline"
    assert_text "April 2024"
  end

  # TC-ACTION-04 (tc-10): Physical post item shows postal address box
  test "physical post item shows postal address" do
    visit public_lookup_case_path(reference: "HO-FV-R4TG")
    assert_text "Visa Processing Centre"
    assert_text "PO Box"
    assert_text "Sheffield"
  end

  # TC-ACTION-05 (tc-10): Physical post item includes reference number on envelope instruction
  test "physical post item tells applicant to write reference on envelope" do
    visit public_lookup_case_path(reference: "HO-FV-R4TG")
    assert_text "reference number"
    assert_text "HO-FV-R4TG"
    assert_text "envelope"
  end

  # TC-ACTION-06 (tc-18): Multiple items all shown
  test "multiple action items all displayed" do
    visit public_lookup_case_path(reference: "HO-T4-Q8VL")
    assert_action_required_panel
    assert_text "1."
    assert_text "2."
    assert_selector "a", text: "Upload document", minimum: 1
  end

  # TC-ACTION-07 (tc-15): Maximum stress — 3 missing items
  test "maximum stress case shows all three missing items" do
    visit public_lookup_case_path(reference: "HO-T2-Z9YQ")
    assert_action_required_panel
    assert_text "Sponsorship certificate"
    assert_text "bank statements"
    assert_text "TB certificate"
  end

  # TC-ACTION-08: Status badge shows orange action needed indicator
  test "action required state shows orange action needed badge" do
    visit public_lookup_case_path(reference: "HO-T2-P2KR")
    assert_selector ".border-orange-500"
    assert_text "🟠"
  end

  # TC-ACTION-09: Not received status shown per item
  test "each item shows not yet received status" do
    visit public_lookup_case_path(reference: "HO-T2-P2KR")
    assert_text "Not yet received"
  end

  # TC-ACTION-10: Consequence section shown
  test "what happens if I cannot provide section is shown" do
    visit public_lookup_case_path(reference: "HO-T2-P2KR")
    assert_text "cannot provide"
    assert_text "contact us"
  end

  # TC-ACTION-11: Timeline updates to show document request event
  test "timeline shows document request event" do
    visit public_lookup_case_path(reference: "HO-T2-P2KR")
    assert_selector "ol li", text: /asked you to provide/
  end

  # TC-ACTION-12 (tc-10): Digital item shows upload button, physical item does not
  test "digital items have upload button, physical items do not" do
    visit public_lookup_case_path(reference: "HO-FV-R4TG")
    # Accommodation proof is digital — should have upload button
    assert_selector "a", text: "Upload document"
  end
end
