import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["icon"]

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
  }

  initializeTheme() {
    const storedTheme = localStorage.getItem("theme")
    const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches
    const theme = storedTheme || (prefersDark ? "dark" : "light")
    
    document.documentElement.setAttribute("data-theme", theme)
    this.updateIcon(theme)
  }

  updateIcon(theme) {
    // Icon content would ideally be SVG paths, but for now we can use emoji or simple text
    // to keep it self-contained, or class toggling if using an icon font.
    // Implementation detail left to the view that uses this controller.
  }
}
