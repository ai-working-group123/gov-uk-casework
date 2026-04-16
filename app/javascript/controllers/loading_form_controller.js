import { Controller } from "@hotwired/stimulus";

// Displays an animated loading overlay with rotating playful messages on form submit
export default class extends Controller {
  static values = { messages: Array };

  messageIndex = 0;
  messageInterval = null;

  defaultMessages = [
    "Reticulating splines...",
    "Consulting the oracle...",
    "Teaching AI about bureaucracy...",
    "Cross-referencing regulations...",
    "Herding digital cats...",
    "Calibrating decision matrices...",
    "Aligning policy vectors...",
    "Untangling red tape...",
    "Brewing a fresh pot of analysis...",
    "Polishing the crystal ball...",
    "Summoning domain experts...",
    "Optimising for common sense...",
    "Reading between the lines...",
    "Connecting the dots...",
    "Warming up the neural pathways...",
    "Fact-checking the fact-checkers...",
  ];

  submit(event) {
    // Allow the form to submit normally, then show the overlay
    requestAnimationFrame(() => this.showOverlay());
  }

  showOverlay() {
    const messages =
      this.hasMessagesValue && this.messagesValue.length
        ? this.messagesValue
        : this.defaultMessages;

    // Shuffle messages
    const shuffled = [...messages].sort(() => Math.random() - 0.5);

    const overlay = document.createElement("div");
    overlay.id = "loading-overlay";
    overlay.innerHTML = `
      <div class="fixed inset-0 bg-white/80 backdrop-blur-sm z-50 flex items-center justify-center">
        <div class="text-center max-w-md mx-auto px-6">
          <!-- Animated dots spinner -->
          <div class="mb-8 flex justify-center">
            <div class="flex gap-2">
              <div class="w-3 h-3 bg-blue-600 rounded-full animate-bounce" style="animation-delay: 0ms;"></div>
              <div class="w-3 h-3 bg-blue-500 rounded-full animate-bounce" style="animation-delay: 150ms;"></div>
              <div class="w-3 h-3 bg-blue-400 rounded-full animate-bounce" style="animation-delay: 300ms;"></div>
              <div class="w-3 h-3 bg-blue-300 rounded-full animate-bounce" style="animation-delay: 450ms;"></div>
            </div>
          </div>

          <!-- Rotating message -->
          <p id="loading-message" class="text-lg font-medium text-gray-700 transition-opacity duration-300">
            ${shuffled[0]}
          </p>

          <!-- Subtle pulsing bar -->
          <div class="mt-6 w-48 h-1 bg-gray-200 rounded-full mx-auto overflow-hidden">
            <div class="h-full bg-blue-500 rounded-full animate-loading-bar"></div>
          </div>

          <p class="text-xs text-gray-400 mt-6">This may take a few moments — please don't close this page.</p>
        </div>
      </div>

      <style>
        @keyframes loading-bar {
          0% { width: 0%; margin-left: 0%; }
          50% { width: 60%; margin-left: 20%; }
          100% { width: 0%; margin-left: 100%; }
        }
        .animate-loading-bar {
          animation: loading-bar 1.8s ease-in-out infinite;
        }
      </style>
    `;

    document.body.appendChild(overlay);

    // Rotate messages every 3 seconds
    let index = 0;
    this.messageInterval = setInterval(() => {
      index = (index + 1) % shuffled.length;
      const messageEl = document.getElementById("loading-message");
      if (messageEl) {
        messageEl.style.opacity = "0";
        setTimeout(() => {
          messageEl.textContent = shuffled[index];
          messageEl.style.opacity = "1";
        }, 300);
      }
    }, 3000);
  }

  disconnect() {
    if (this.messageInterval) {
      clearInterval(this.messageInterval);
    }
    const overlay = document.getElementById("loading-overlay");
    if (overlay) overlay.remove();
  }
}
