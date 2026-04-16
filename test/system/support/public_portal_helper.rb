# frozen_string_literal: true

# Shared helpers for all public portal system tests
module PublicPortalHelper
  def visit_lookup
    visit lookup_path
  end

  def submit_reference(reference)
    visit_lookup
    fill_in "reference", with: reference
    click_button "Check status"
  end

  def assert_govuk_header
    assert_selector "div[style*='1D70B8']", wait: 5
    assert_text "GOV"
    assert_text "UK"
  end

  def assert_action_required_panel
    assert_text "Action needed"
    assert_text "we need documents from you"
  end

  def assert_passive_status_panel
    assert_selector ".border-blue-500"
    assert_text "Awaiting evidence"
  end

  def assert_timeline_entry(text)
    assert_selector "ol li", text: text
  end

  def assert_upload_button_for(document_name)
    assert_selector "a", text: "Upload document"
    assert_text document_name
  end
end
