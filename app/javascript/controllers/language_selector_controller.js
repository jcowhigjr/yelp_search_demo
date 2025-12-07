import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]
  static values = { open: Boolean }

  connect() {
    // Close dropdown when clicking outside
    document.addEventListener('click', this.closeOnClickOutside.bind(this))
    
    // Close dropdown when pressing Escape
    document.addEventListener('keydown', this.closeOnEscape.bind(this))
  }

  disconnect() {
    document.removeEventListener('click', this.closeOnClickOutside.bind(this))
    document.removeEventListener('keydown', this.closeOnEscape.bind(this))
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()
    
    this.openValue = !this.openValue
    this.updateMenuState()
  }

  open() {
    this.openValue = true
    this.updateMenuState()
  }

  close() {
    this.openValue = false
    this.updateMenuState()
  }

  updateMenuState() {
    if (this.menuTarget) {
      this.menuTarget.hidden = !this.openValue
      
      // Update button aria-expanded
      const button = this.element.querySelector('button')
      if (button) {
        button.setAttribute('aria-expanded', this.openValue.toString())
      }
    }
  }

  closeOnClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  closeOnEscape(event) {
    if (event.key === 'Escape' && this.openValue) {
      this.close()
    }
  }
}
