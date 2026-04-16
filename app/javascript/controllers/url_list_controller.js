import { Controller } from "@hotwired/stimulus";

// Manages dynamic URL input fields — add/remove
export default class extends Controller {
  static targets = ["container", "entry"];

  add() {
    const template = `
      <div class="flex gap-2" data-url-list-target="entry">
        <input
          type="url"
          name="urls[]"
          class="flex-1 border border-gray-300 rounded-lg px-4 py-2.5 text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
          placeholder="https://www.gov.uk/..."
        >
        <button
          type="button"
          data-action="url-list#remove"
          class="text-red-400 hover:text-red-600 px-2 text-lg transition-colors"
          title="Remove URL"
        >&times;</button>
      </div>
    `;
    this.containerTarget.insertAdjacentHTML("beforeend", template);
  }

  remove(event) {
    const entry = event.target.closest("[data-url-list-target='entry']");
    if (this.entryTargets.length > 1) {
      entry.remove();
    }
  }
}
