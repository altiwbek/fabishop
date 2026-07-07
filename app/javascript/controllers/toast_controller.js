import { Controller } from "@hotwired/stimulus"

// Auto-dismissing flash toast injected by Turbo Streams.
export default class extends Controller {
  static values = { delay: { type: Number, default: 3200 } }

  connect() {
    this.timeout = setTimeout(() => this.dismiss(), this.delayValue)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }

  dismiss() {
    this.element.style.transition = "opacity .4s"
    this.element.style.opacity = "0"
    setTimeout(() => this.element.remove(), 400)
  }
}
