require "application_system_test_case"
require_relative "support/public_portal_helper"

# =============================================================================
# TC-UPLOAD: Document Upload Page (Screen 7)
# Covers the upload journey for digital submission items
# Test cases: tc-04 (TB cert), tc-07 (bank statements), tc-18 (multiple)
# =============================================================================
class DocumentUploadTest < ApplicationSystemTestCase
  include PublicPortalHelper

  # TC-UPLOAD-01: Upload page renders with document name
  test "upload page shows correct document name in heading" do
    item = evidence_request_items(:tc04_tb_item)
    visit public_lookup_upload_form_path(reference: "HO-T2-P2KR", item_id: item.id)
    assert_govuk_header
    assert_text "Upload document"
    assert_text "TB certificate"
  end

  # TC-UPLOAD-02: Application reference shown on upload page
  test "upload page shows application reference" do
    item = evidence_request_items(:tc04_tb_item)
    visit public_lookup_upload_form_path(reference: "HO-T2-P2KR", item_id: item.id)
    assert_text "HO-T2-P2KR"
  end

  # TC-UPLOAD-03: File requirements listed
  test "upload page shows accepted file types and size limit" do
    item = evidence_request_items(:tc04_tb_item)
    visit public_lookup_upload_form_path(reference: "HO-T2-P2KR", item_id: item.id)
    assert_text "PDF"
    assert_text "JPG"
    assert_text "PNG"
    assert_text "10MB"
  end

  # TC-UPLOAD-04: File quality guidance shown
  test "upload page shows quality guidance" do
    item = evidence_request_items(:tc04_tb_item)
    visit public_lookup_upload_form_path(reference: "HO-T2-P2KR", item_id: item.id)
    assert_text "clear, readable"
  end

  # TC-UPLOAD-05: File upload input rendered
  test "upload page renders file upload input" do
    item = evidence_request_items(:tc04_tb_item)
    visit public_lookup_upload_form_path(reference: "HO-T2-P2KR", item_id: item.id)
    assert_selector "input[type='file']"
  end

  # TC-UPLOAD-06: File upload label rendered
  test "upload page has file upload label" do
    item = evidence_request_items(:tc04_tb_item)
    visit public_lookup_upload_form_path(reference: "HO-T2-P2KR", item_id: item.id)
    assert_selector "label[for='document']"
  end

  # TC-UPLOAD-07: Optional note field present
  test "upload page has optional note textarea" do
    item = evidence_request_items(:tc04_tb_item)
    visit public_lookup_upload_form_path(reference: "HO-T2-P2KR", item_id: item.id)
    assert_text "anything else you want to tell us"
    assert_selector "textarea#note"
  end

  # TC-UPLOAD-08: Optional note field is clearly optional
  test "optional note field is labelled as optional" do
    item = evidence_request_items(:tc04_tb_item)
    visit public_lookup_upload_form_path(reference: "HO-T2-P2KR", item_id: item.id)
    assert_text "Optional"
  end

  # TC-UPLOAD-09: Upload button present
  test "upload page has upload document submit button" do
    item = evidence_request_items(:tc04_tb_item)
    visit public_lookup_upload_form_path(reference: "HO-T2-P2KR", item_id: item.id)
    assert_selector "button", text: "Upload document"
  end

  # TC-UPLOAD-10: Back link returns to status page
  test "back link returns to application status page" do
    item = evidence_request_items(:tc04_tb_item)
    visit public_lookup_upload_form_path(reference: "HO-T2-P2KR", item_id: item.id)
    click_link "Back"
    assert_current_path(/lookup/)
  end

  # TC-UPLOAD-11: Cancel link back to status present
  test "upload page shows cancel link back to status" do
    item = evidence_request_items(:tc04_tb_item)
    visit public_lookup_upload_form_path(reference: "HO-T2-P2KR", item_id: item.id)
    assert_selector "a", text: "Cancel and return to your application"
  end

  # TC-UPLOAD-12: Cancel link navigates to status page
  test "cancel link returns to application status" do
    item = evidence_request_items(:tc04_tb_item)
    visit public_lookup_upload_form_path(reference: "HO-T2-P2KR", item_id: item.id)
    click_link "Cancel and return to your application"
    assert_current_path(/lookup/)
  end

  # TC-UPLOAD-13 (tc-07): Upload works for financial evidence item
  test "upload page works for financial evidence" do
    item = evidence_request_items(:tc07_bank_item)
    visit public_lookup_upload_form_path(reference: "HO-T4-E5RW", item_id: item.id)
    assert_text "Upload document"
    assert_text "HO-T4-E5RW"
  end

  # TC-UPLOAD-14 (tc-18): Upload page for second item in multi-item request
  test "upload page works for second item in multi-item request" do
    item = evidence_request_items(:tc18_english_item)
    visit public_lookup_upload_form_path(reference: "HO-T4-Q8VL", item_id: item.id)
    assert_text "Upload document"
    assert_text "HO-T4-Q8VL"
  end
end
