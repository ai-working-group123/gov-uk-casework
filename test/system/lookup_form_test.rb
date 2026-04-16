require "application_system_test_case"
require_relative "support/public_portal_helper"

# =============================================================================
# TC-LOOKUP: Lookup Form (Screen 4)
# Tests the entry point for all public journey flows
# =============================================================================
class LookupFormTest < ApplicationSystemTestCase
  include PublicPortalHelper

  # TC-LOOKUP-01: Page renders with correct 2025 GOV.UK branding
  test "lookup form displays 2025 GOV.UK rebrand header" do
    visit_lookup
    assert_govuk_header
    assert_selector "div[style*='#1D70B8']"   # blue header
    assert_text "GOV"
    assert_selector "span[style*='#00FFE0']"  # teal dot
  end

  # TC-LOOKUP-02: Page renders correct form elements
  test "lookup form displays reference input and submit button" do
    visit_lookup
    assert_selector "input#reference"
    assert_selector "button", text: "Check status"
    assert_text "Enter your application reference number"
  end

  # TC-LOOKUP-03: Help text shown for reference format
  test "lookup form shows reference format hint" do
    visit_lookup
    assert_text "For example, VIS-2024-00847"
  end

  # TC-LOOKUP-04: Submitting a reference navigates to status page
  test "submitting a reference navigates to status page" do
    submit_reference "HO-T2-A3F9"
    assert_current_path(/lookup/)
  end

  # TC-LOOKUP-05: Page title is set correctly
  test "lookup page has correct page title" do
    visit_lookup
    assert_title(/GOV\.UK|visa application/)
  end

  # TC-LOOKUP-06: Footer renders
  test "lookup page renders GOV.UK footer" do
    visit_lookup
    assert_selector "footer"
    assert_text "Crown copyright"
  end
end
