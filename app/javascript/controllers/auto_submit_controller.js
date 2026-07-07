import { Controller } from "@hotwired/stimulus"

// Submits the form (via Turbo) as soon as an input changes.
export default class extends Controller {
  submit() {
    this.element.requestSubmit()
  }
}
