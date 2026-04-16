# frozen_string_literal: true

# Shared helpers for all public portal system tests
module PublicPortalHelper
  def visit_lookup
    visit public_lookup_path
  end

  def submit_reference(reference)
    visit_lookup
    fill_in "reference", with: reference
    click_button "Find application"
  end

  def assert_govuk_header
    assert_selector ".govuk-header", wait: 5
    assert_text "GOV.UK"
  end

  def assert_action_required_panel
    assert_selector ".govuk-tag--yellow", text: /action required/i
  end

  def assert_passive_status_panel
    assert_selector ".govuk-tag--blue"
  end
end
