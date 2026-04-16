import { Controller } from "@hotwired/stimulus";

// Toggle between preview and edit mode for markdown sections
export default class extends Controller {
  static targets = ["preview", "editor", "editBtn", "textarea", "hiddenField"];

  originalContent = "";

  get textareaEl() {
    return this.hasTextareaTarget
      ? this.textareaTarget
      : this.editorTarget.querySelector("textarea");
  }

  toggleEdit() {
    const isEditing = !this.editorTarget.classList.contains("hidden");
    if (isEditing) {
      this.cancelEdit();
    } else {
      this.originalContent = this.textareaEl?.value || "";
      this.previewTarget.classList.add("hidden");
      this.editorTarget.classList.remove("hidden");
      this.editBtnTarget.textContent = "Cancel";
    }
  }

  cancelEdit() {
    if (this.textareaEl) this.textareaEl.value = this.originalContent;
    this.editorTarget.classList.add("hidden");
    this.previewTarget.classList.remove("hidden");
    this.editBtnTarget.textContent = "Edit";
  }

  saveEdit() {
    // Sync edited content to hidden field for form submission
    if (this.hasHiddenFieldTarget && this.textareaEl) {
      this.hiddenFieldTarget.value = this.textareaEl.value;
    }
    this.editorTarget.classList.add("hidden");
    this.previewTarget.classList.remove("hidden");
    this.editBtnTarget.textContent = "Edit";
  }
}
