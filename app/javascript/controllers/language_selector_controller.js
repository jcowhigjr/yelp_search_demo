import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="language-selector"
export default class extends Controller {
  static targets = ["button", "menu"]

  connect() {
    this.boundHide = this.hide.bind(this)
  }

  toggle() {
    if (this.menuTarget.classList.contains("is-open")) {
      this.hide()
    } else {
      this.show()
    }
  }

  show() {
    this.menuTarget.classList.add("is-open")
    this.buttonTarget.setAttribute("aria-expanded", "true")
    document.addEventListener("click", this.boundHide, { once: true })
    this.menuTarget.addEventListener("keydown", this.handleKeydown.bind(this))
  }

  hide(event) {
    if (event && this.element.contains(event.target)) {
      return
    }
    this.menuTarget.classList.remove("is-open")
    this.buttonTarget.setAttribute("aria-expanded", "false")
    document.removeEventListener("click", this.boundHide)
  }

  select() {
    this.hide()
  }

  handleKeydown(event) {
    switch (event.key) {
      case "Escape":
        this.hide()
        this.buttonTarget.focus()
        break
      case "ArrowDown":
        event.preventDefault()
        this.focusNextItem()
        break
      case "ArrowUp":
        event.preventDefault()
        this.focusPreviousItem()
        break
    }
  }

  get menuItems() {
    return Array.from(this.menuTarget.querySelectorAll("[role='menuitem']"))
  }

  focusNextItem() {
    const activeElement = document.activeElement
    const currentIndex = this.menuItems.indexOf(activeElement)
    const nextIndex = (currentIndex + 1) % this.menuItems.length
    this.menuItems[nextIndex].focus()
  }

  focusPreviousItem() {
    const activeElement = document.activeElement
    const currentIndex = this.menuItems.indexOf(activeElement)
    const previousIndex = (currentIndex - 1 + this.menuItems.length) % this.menuItems.length
    this.menuItems[previousIndex].focus()
  }
}
