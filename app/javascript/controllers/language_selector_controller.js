import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]
<<<<<<< Updated upstream
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

=======
  
  connect() {
    // Close dropdown when clicking outside
    document.addEventListener('click', this.closeOnClickOutside.bind(this))
  }
  
  disconnect() {
    document.removeEventListener('click', this.closeOnClickOutside.bind(this))
  }
  
>>>>>>> Stashed changes
  toggle(event) {
    event.preventDefault()
    event.stopPropagation()
    
<<<<<<< Updated upstream
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
=======
    const isExpanded = this.menuTarget.hidden
    
    if (isExpanded) {
      this.show()
    } else {
      this.hide()
    }
  }
  
  show() {
    this.menuTarget.hidden = false
    this.element.setAttribute('aria-expanded', 'true')
  }
  
  hide() {
    this.menuTarget.hidden = true
    this.element.setAttribute('aria-expanded', 'false')
  }
  
  closeOnClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hide()
>>>>>>> Stashed changes
    }
  }
}
