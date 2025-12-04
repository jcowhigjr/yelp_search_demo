import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "menu", "item"]
  static values = { open: Boolean }

  connect() {
    this.handleOutsideClick = this.handleOutsideClick.bind(this)
    this.handleGlobalKeydown = this.handleGlobalKeydown.bind(this)
    document.addEventListener("click", this.handleOutsideClick)
    document.addEventListener("keydown", this.handleGlobalKeydown)
    this.close()
  }

  disconnect() {
    document.removeEventListener("click", this.handleOutsideClick)
    document.removeEventListener("keydown", this.handleGlobalKeydown)
  }

  toggle(event) {
    event.preventDefault()
    this.openValue ? this.close() : this.open()
  }

  handleButtonKeydown(event) {
    if (["Enter", " "].includes(event.key)) {
      event.preventDefault()
      this.open()
      this.focusFirstItem()
    }

    if (event.key === "ArrowDown") {
      event.preventDefault()
      this.open()
      this.focusFirstItem()
    }
  }

  handleGlobalKeydown(event) {
    if (!this.openValue) return

    if (event.key === "Escape") {
      this.close()
      this.buttonTarget.focus()
      return
    }

    if (event.key === "ArrowDown") {
      event.preventDefault()
      this.focusNextItem()
    }

    if (event.key === "ArrowUp") {
      event.preventDefault()
      this.focusPreviousItem()
    }
  }

  handleOutsideClick(event) {
    if (!this.openValue) return
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  open() {
    this.openValue = true
    this.buttonTarget.setAttribute("aria-expanded", "true")
    this.menuTarget.hidden = false
    this.element.classList.add("language-selector--open")
  }

  close(event) {
    this.openValue = false
    this.buttonTarget.setAttribute("aria-expanded", "false")
    this.menuTarget.hidden = true
    this.element.classList.remove("language-selector--open")
  }

  focusFirstItem() {
    const firstItem = this.items[0]
    if (firstItem) firstItem.focus()
  }

  focusNextItem() {
    if (this.items.length === 0) return
    const activeIndex = this.items.findIndex((item) => item === document.activeElement)
    const nextIndex = (activeIndex + 1) % this.items.length
    this.items[nextIndex].focus()
  }

  focusPreviousItem() {
    if (this.items.length === 0) return
    const activeIndex = this.items.findIndex((item) => item === document.activeElement)
    const previousIndex = (activeIndex - 1 + this.items.length) % this.items.length
    this.items[previousIndex].focus()
  }

  get items() {
    return this.itemTargets
  }
}
