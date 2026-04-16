import { Controller } from "@hotwired/stimulus";

// Steps through clarifying questions one at a time
export default class extends Controller {
  static targets = ["card", "submitArea"];

  connect() {
    // Start at the first visible card (set by the server based on first unanswered)
    this.currentIndex = this.cardTargets.findIndex(
      (card) => card.style.display !== "none",
    );
    if (this.currentIndex === -1) this.currentIndex = 0;

    // Show submit area if we're on the last question
    if (this.currentIndex === this.cardTargets.length - 1) {
      this.submitAreaTarget.style.display = "block";
    }
  }

  next() {
    // Hide current card
    this.cardTargets[this.currentIndex].style.display = "none";

    // Show next card
    this.currentIndex++;
    if (this.currentIndex < this.cardTargets.length) {
      this.cardTargets[this.currentIndex].style.display = "block";
    }

    // Show submit area on last question
    if (this.currentIndex === this.cardTargets.length - 1) {
      this.submitAreaTarget.style.display = "block";
    }
  }

  prev() {
    if (this.currentIndex <= 0) return;

    // Hide submit area when going back from last question
    if (this.currentIndex === this.cardTargets.length - 1) {
      this.submitAreaTarget.style.display = "none";
    }

    // Hide current card
    this.cardTargets[this.currentIndex].style.display = "none";

    // Show previous card
    this.currentIndex--;
    this.cardTargets[this.currentIndex].style.display = "block";
  }

  selectAnswer(event) {
    // Clear custom input when a radio is selected
    const card = event.target.closest(".question-card");
    const customInput = card.querySelector("input[type='text']");
    if (customInput) customInput.value = "";

    // Uncheck skip
    const skipCheckbox = card.querySelector("input[type='checkbox']");
    if (skipCheckbox) skipCheckbox.checked = false;
  }

  customAnswer(event) {
    // Deselect radio buttons when custom answer is typed
    const card = event.target.closest(".question-card");
    const radios = card.querySelectorAll("input[type='radio']");
    radios.forEach((r) => (r.checked = false));

    // Uncheck skip
    const skipCheckbox = card.querySelector("input[type='checkbox']");
    if (skipCheckbox) skipCheckbox.checked = false;
  }

  skipAnswer(event) {
    if (event.target.checked) {
      const card = event.target.closest(".question-card");
      // Clear radio selections
      const radios = card.querySelectorAll("input[type='radio']");
      radios.forEach((r) => (r.checked = false));
      // Clear custom input
      const customInput = card.querySelector("input[type='text']");
      if (customInput) customInput.value = "";
    }
  }
}
