import { Controller } from "@hotwired/stimulus";

// Monitors forms on the page for unsaved changes.
// When dirty, future step links in the progress bar are disabled.
export default class extends Controller {
  static targets = ["futureLink"];

  connect() {
    this.dirty = false;
    this.form = document.querySelector("form");

    if (this.form) {
      this.form.addEventListener("input", this._markDirty);
      this.form.addEventListener("change", this._markDirty);
      this.form.addEventListener("submit", this._markClean);
    }
  }

  disconnect() {
    if (this.form) {
      this.form.removeEventListener("input", this._markDirty);
      this.form.removeEventListener("change", this._markDirty);
      this.form.removeEventListener("submit", this._markClean);
    }
  }

  _markDirty = () => {
    if (this.dirty) return;
    this.dirty = true;

    this.futureLinkTargets.forEach((link) => {
      link.dataset.href = link.getAttribute("href");
      link.removeAttribute("href");
      link.classList.add("opacity-40", "cursor-not-allowed");
      link.classList.remove("hover:text-gray-600", "hover:underline");
      link.setAttribute("tabindex", "-1");
      link.setAttribute(
        "title",
        "Save or submit your changes before moving forward",
      );
    });

    this._showWarning();
  };

  _markClean = () => {
    this.dirty = false;

    this.futureLinkTargets.forEach((link) => {
      if (link.dataset.href) {
        link.setAttribute("href", link.dataset.href);
        delete link.dataset.href;
      }
      link.classList.remove("opacity-40", "cursor-not-allowed");
      link.classList.add("hover:text-gray-600", "hover:underline");
      link.removeAttribute("tabindex");
      link.removeAttribute("title");
    });

    this._hideWarning();
  };

  _showWarning() {
    if (this.element.querySelector("[data-dirty-warning]")) return;

    const warning = document.createElement("div");
    warning.setAttribute("data-dirty-warning", "");
    warning.className = "mt-2 text-xs text-amber-600 flex items-center gap-1";
    warning.innerHTML = `
      <svg class="w-4 h-4 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
        <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/>
      </svg>
      You have unsaved changes — submit this step before moving forward
    `;
    this.element.appendChild(warning);
  }

  _hideWarning() {
    const warning = this.element.querySelector("[data-dirty-warning]");
    if (warning) warning.remove();
  }
}
