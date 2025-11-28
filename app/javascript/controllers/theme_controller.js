import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["icon", "button"]

  connect() {
    this.initializeTheme()
  }

  toggle() {
    const html = document.documentElement
    const currentTheme = html.getAttribute("data-theme")
    const newTheme = currentTheme === "dark" ? "light" : "dark"
    
    html.setAttribute("data-theme", newTheme)
    localStorage.setItem("theme", newTheme)
    this.updateIcon(newTheme)
    this.updateButtonStyle(newTheme)
  }

  initializeTheme() {
    const storedTheme = localStorage.getItem("theme")
    const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches
    const theme = storedTheme || (prefersDark ? "dark" : "light")
    
    document.documentElement.setAttribute("data-theme", theme)
    this.updateIcon(theme)
    this.updateButtonStyle(theme)
  }

  updateIcon(theme) {
    if (this.hasIconTarget) {
      this.iconTarget.textContent = theme === "dark" ? "light_mode" : "dark_mode"
    }
  }

  updateButtonStyle(theme) {
    if (this.hasButtonTarget) {
      const button = this.buttonTarget
      if (theme === "dark") {
        button.style.backgroundColor = 'var(--color-bg)'
        button.style.color = 'var(--color-text)'
        button.style.border = '1px solid var(--color-border)'
      } else {
        button.style.backgroundColor = 'var(--color-primary)'
        button.style.color = 'white'
        button.style.border = 'none'
      }
    }
  }
}
