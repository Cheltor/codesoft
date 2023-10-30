// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import * as bootstrap from "bootstrap"

// AdminKit (required)
import "./modules/sidebar";
import "./modules/theme";
import "./modules/feather";

// Charts
import "./modules/chartjs";

// Forms
import "./modules/flatpickr";

// Maps
import "./modules/vector-maps";


// Initialize ChoicesJS

document.addEventListener('turbo:load', initializeChoices);
document.addEventListener('DOMContentLoaded', initializeChoices);

function initializeChoices() {
  var selectElements = document.querySelectorAll('.choices-select');
  selectElements.forEach(function (select) {
    new Choices(select);
  });
}

// PWA
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/service-worker.js')
      .then((registration) => {
        console.log('Service Worker registered with scope:', registration.scope);
      })
      .catch((error) => {
        console.log('Service Worker registration failed:', error);
      });
  });
}