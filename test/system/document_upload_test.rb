require "application_system_test_case"
require_relative "support/public_portal_helper"

# =============================================================================
# TC-UPLOAD: Document Upload Page (Screen 7)
# Covers the upload journey for digital submission items
# Test cases: tc-04 (TB cert), tc-07 (bank statements), tc-18 (multiple)
# =============================================================================
class DocumentUploadTest < ApplicationSystemTestCase
  include PublicPortalHelper

  # TC-UPLOAD-01: Upload page renders with document name in heading
  test "upload page shows correct document name in heading" do
    visit lookup_upload_form_path("HO-T2-P2KR", 1)
    assert_govuk_header
    assert_text "Upload document"
    assert_text "Sponsorship certificate"
  end

  # TC-UPLOAD-02: Application reference shown on upload page
  test "upload page shows application reference" do
    visit lookup_upload_form_path("HO-T2-P2KR", 1)
    assert_text "HO-T2-P2KR"
  end

  # TC-UPLOAD-03: File requirements listed
  test "upload page shows accepted file types and size limit" do
    visit lookup_upload_form_path("HO-T2-P2KR", 1)
    assert_text "PDF"
    assert_text "JPG"
    assert_text "PNG"
    assert_text "10MB"
  end

  # TC-UPLOAD-04: File quality guidance shown
  test "upload page shows quality guidance" do
    visit lookup_upload_form_path("HO-T2-P2KR", 1)
    assert_text "clear, readable"
  end

  # TC-UPLOAD-05: Upload dropzone rendered
  test "upload page renders drag and drop zone" do
    visit lookup_upload_form_path("HO-T2-P2KR", 1)
    assert_text "Drag and drop"
    assert_selector "input[type='file']", visible: :hidden
  end

  # TC-UPLOAD-06: Choose file button rendered
  test "upload page has choose file button" do
    visit lookup_upload_form_path("HO-T2-P2KR", 1)
    assert_selector "label", text: "Choose file"
  end

  # TC-UPLOAD-07: Optional note field present
  test "upload page has optional note textarea" do
    visit lookup_upload_form_path("HO-T2-P2KR", 1)
    assert_text "anything else you want to tell us"
    assert_selector "textarea#note"
  end

  # TC-UPLOAD-08: Optional note field is clearly optional
  test "optional note field is labelled as optional" do
    visit lookup_upload_form_path("HO-T2-P2KR", 1)
    assert_text "optional"
  end

  # TC-UPLOAD-09: Upload button present
  test "upload page has upload document submit button" do
    visit lookup_upload_form_path("HO-T2-P2KR", 1)
    assert_selector "button", text: "Upload document"
  end

  # TC-UPLOAD-10: Back link returns to status page
  test "back link returns to application status page" do
    visit lookup_upload_form_path("HO-T2-P2KR", 1)
    assert_selector "a", text: /Back to/
    click_link "Back"
    assert_current_path(/lookup/)
  end

  # TC-UPLOAD-11: Success state visible in wireframe (static)
  test "upload page shows success confirmation panel in wireframe" do
    visit lookup_upload_form_path("HO-T2-P2KR", 1)
    assert_text "uploaded successfully"
    assert_text "Return to your application status"
  end

  # TC-UPLOAD-12: Return to status link present after upload
  test "return to application link present" do
    visit lookup_upload_form_path("HO-T2-P2KR", 1)
    assert_selector "a", text: "Return to your application status"
  end

  # TC-UPLOAD-13 (tc-07): Upload works for financial evidence item
  test "upload page works for financial evidence" do
    visit lookup_upload_form_path("HO-T4-E5RW", 1)
    assert_text "Upload document"
    assert_text "HO-T4-E5RW"
  end

  # TC-UPLOAD-14 (tc-18): Upload page for second item in multi-item request
  test "upload page works for second item in multi-item request" do
    visit lookup_upload_form_path("HO-T4-Q8VL", 2)
    assert_text "Upload document"
    assert_text "HO-T4-Q8VL"
  end
end
