require "application_system_test_case"
require_relative "support/public_portal_helper"

# =============================================================================
# TC-BRAND: GOV.UK 2025 Rebrand Compliance Tests
# Validates correct brand colours, typography, and layout across all screens
# Brand spec: https://brand.design-system.service.gov.uk/colour/govuk-blue/
#   Primary blue: #1D70B8
#   Accent teal:  #00FFE0
#   GDS green:    #00703c (buttons)
# =============================================================================
class GovukBrandComplianceTest < ApplicationSystemTestCase
  include PublicPortalHelper

  BRAND_BLUE  = "#1D70B8"
  ACCENT_TEAL = "#00FFE0"
  GDS_GREEN   = "#00703c"

  # TC-BRAND-01: Lookup page has primary blue header
  test "lookup page header uses 2025 primary blue" do
    visit lookup_path
    header = find("div[style*='#{BRAND_BLUE}']")
    assert header.visible?
  end

  # TC-BRAND-02: Status page has primary blue header
  test "status page header uses 2025 primary blue" do
    visit lookup_case_path("HO-T2-A3F9")
    assert_selector "div[style*='#{BRAND_BLUE}']"
  end

  # TC-BRAND-03: Upload page has primary blue header
  test "upload page header uses 2025 primary blue" do
    visit lookup_upload_form_path("HO-T2-P2KR", 1)
    assert_selector "div[style*='#{BRAND_BLUE}']"
  end

  # TC-BRAND-04: Teal dot visible in header wordmark
  test "GOV.UK wordmark shows teal dot on all public pages" do
    [ lookup_path,
      lookup_case_path("HO-T2-A3F9"),
      lookup_upload_form_path("HO-T2-P2KR", 1) ].each do |path|
      visit path
      assert_selector "span[style*='#{ACCENT_TEAL}']", wait: 3
    end
  end

  # TC-BRAND-05: Primary action buttons use GDS green
  test "submit buttons use GDS green colour" do
    visit lookup_path
    btn = find("button", text: "Check status")
    assert_match(/00703c/, btn["style"].to_s)
  end

  # TC-BRAND-06: Check status button on upload page uses GDS green
  test "upload button uses GDS green colour" do
    visit lookup_upload_form_path("HO-T2-P2KR", 1)
    btn = find("button", text: "Upload document")
    assert_match(/00703c/, btn["style"].to_s)
  end

  # TC-BRAND-07: Service name bar has blue underline border
  test "service name bar has 2025 brand blue bottom border" do
    visit lookup_path
    assert_selector "div[style*='#{BRAND_BLUE}']"
  end

  # TC-BRAND-08: No old black GOV.UK header present
  test "old black GOV.UK header style is not present" do
    visit lookup_path
    assert_no_selector "div.bg-black"
  end

  # TC-BRAND-09: GOV.UK wordmark text present on all public pages
  test "GOV.UK wordmark text visible on all public pages" do
    [ lookup_path,
      lookup_case_path("HO-T2-A3F9"),
      lookup_case_path("HO-T2-P2KR", action_required: true),
      lookup_upload_form_path("HO-T2-P2KR", 1) ].each do |path|
      visit path
      within("header, div[style*='#{BRAND_BLUE}']") do
        assert_text "GOV"
        assert_text "UK"
      end
    end
  end

  # TC-BRAND-10: Crown copyright in footer
  test "footer shows Crown copyright on all public pages" do
    [ lookup_path, lookup_case_path("HO-T2-A3F9") ].each do |path|
      visit path
      assert_selector "footer", text: /Crown copyright/
    end
  end

  # TC-BRAND-11: Links use brand blue colour
  test "back links use brand blue colour" do
    visit lookup_case_path("HO-T2-A3F9")
    back_link = find("a", text: /Check another application/)
    assert_match(/1D70B8/, back_link["style"].to_s)
  end
end
