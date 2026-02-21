import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['input', 'clearButton'];

  connect() {
    this.toggleClearButton();
  }

  toggleClearButton() {
    const hasValue = this.inputTarget.value.length > 0;
    if (hasValue) {
      this.clearButtonTarget.classList.remove('clear-button-hidden');
    } else {
      this.clearButtonTarget.classList.add('clear-button-hidden');
    }
  }
}
