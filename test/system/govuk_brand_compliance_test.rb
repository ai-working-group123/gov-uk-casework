require "application_system_test_case"
require_relative "support/public_portal_helper"

# =============================================================================
# TC-BRAND: GOV.UK Design System Compliance Tests
# Validates correct use of GOV.UK Design System components across all screens
# =============================================================================
class GovukBrandComplianceTest < ApplicationSystemTestCase
  include PublicPortalHelper

  # TC-BRAND-01: Lookup page uses GOV.UK Design System header
  test "lookup page header uses GOV.UK design system header" do
    visit public_lookup_path
    assert_selector ".govuk-header"
  end

  # TC-BRAND-02: Status page uses GOV.UK Design System header
  test "status page header uses GOV.UK design system header" do
    visit public_lookup_case_path(reference: "HO-T2-A3F9")
    assert_selector ".govuk-header"
  end

  # TC-BRAND-03: Upload page uses GOV.UK Design System header
  test "upload page header uses GOV.UK design system header" do
    item = evidence_request_items(:tc04_tb_item)
    visit public_lookup_upload_form_path(reference: "HO-T2-P2KR", item_id: item.id)
    assert_selector ".govuk-header"
  end

  # TC-BRAND-04: GOV.UK logo dot visible on all public pages
  test "GOV.UK logo dot visible on all public pages" do
    item = evidence_request_items(:tc04_tb_item)
    [ public_lookup_path,
      public_lookup_case_path(reference: "HO-T2-A3F9"),
      public_lookup_upload_form_path(reference: "HO-T2-P2KR", item_id: item.id) ].each do |path|
      visit path
      assert_selector ".govuk-header__logotype", wait: 3
    end
  end

  # TC-BRAND-05: Primary action buttons use GOV.UK button style
  test "submit buttons use GOV.UK button style" do
    visit public_lookup_path
    assert_selector "button.govuk-button", text: "Find application"
  end

  # TC-BRAND-06: Upload page button uses GOV.UK button style
  test "upload button uses GOV.UK button style" do
    item = evidence_request_items(:tc04_tb_item)
    visit public_lookup_upload_form_path(reference: "HO-T2-P2KR", item_id: item.id)
    assert_selector "button.govuk-button", text: "Upload document"
  end

  # TC-BRAND-07: Service name displayed in header
  test "service name displayed in header" do
    visit public_lookup_path
    assert_text "Check your application status"
  end

  # TC-BRAND-08: No old black GOV.UK header present
  test "old black GOV.UK header style is not present" do
    visit public_lookup_path
    assert_no_selector "div.bg-black"
  end

  # TC-BRAND-09: GOV.UK wordmark text present on all public pages
  test "GOV.UK wordmark text visible on all public pages" do
    item = evidence_request_items(:tc04_tb_item)
    [ public_lookup_path,
      public_lookup_case_path(reference: "HO-T2-A3F9"),
      public_lookup_case_path(reference: "HO-T2-P2KR"),
      public_lookup_upload_form_path(reference: "HO-T2-P2KR", item_id: item.id) ].each do |path|
      visit path
      assert_text "GOV.UK"
    end
  end

  # TC-BRAND-10: Crown copyright in footer
  test "footer shows Crown copyright on all public pages" do
    [ public_lookup_path, public_lookup_case_path(reference: "HO-T2-A3F9") ].each do |path|
      visit path
      assert_selector "footer", text: /Crown copyright/
    end
  end

  # TC-BRAND-11: Links use GOV.UK link style
  test "links use GOV.UK link style" do
    visit public_lookup_case_path(reference: "HO-T2-A3F9")
    assert_selector "a.govuk-link", text: "Check a different reference"
  end
end
