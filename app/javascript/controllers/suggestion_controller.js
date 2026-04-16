import { Controller } from "@hotwired/stimulus";

// Controls individual suggestion card — toggle comment area opacity when unchecked
export default class extends Controller {
  static targets = ["checkbox", "commentArea"];

  toggle() {
    const checked = this.checkboxTarget.checked;
    if (this.hasCommentAreaTarget) {
      this.commentAreaTarget.style.opacity = checked ? "1" : "0.4";
    }
  }
}
