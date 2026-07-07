import { Controller } from "@hotwired/stimulus"

// Live product search-as-you-type. Fetches an HTML fragment and injects it
// into the results dropdown. Works even with Turbo Drive disabled.
export default class extends Controller {
  static targets = ["input", "results"]

  connect() {
    this.timeout = null
    this.onOutsideClick = this.hideIfOutside.bind(this)
    document.addEventListener("click", this.onOutsideClick)
  }

  disconnect() {
    document.removeEventListener("click", this.onOutsideClick)
    clearTimeout(this.timeout)
  }

  search() {
    clearTimeout(this.timeout)
    const q = this.inputTarget.value.trim()
    if (q.length < 2) {
      this.clear()
      return
    }
    this.timeout = setTimeout(() => this.fetch(q), 220)
  }

  async fetch(q) {
    try {
      const res = await fetch(`/search?q=${encodeURIComponent(q)}&variant=autocomplete`, {
        headers: { "Accept": "text/html", "X-Requested-With": "XMLHttpRequest" }
      })
      this.resultsTarget.innerHTML = await res.text()
    } catch (_) {
      this.clear()
    }
  }

  clear() {
    this.resultsTarget.innerHTML = ""
  }

  hideIfOutside(event) {
    if (!this.element.contains(event.target)) this.clear()
  }
}
