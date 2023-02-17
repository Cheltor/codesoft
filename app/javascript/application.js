// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import * as bootstrap from "bootstrap"
import Choices from 'choices.js';
import '/choices.js';

// Instantiate the Choices object on the select element
document.addEventListener('DOMContentLoaded', () => {
  const selectElement = document.querySelector('#code-select');
  const codeSelect = new Choices(selectElement, {
    removeItemButton: true,
    searchEnabled: true,
    placeholder: true,
    placeholderValue: 'Select codes',
  });
});