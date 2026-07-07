import { Controller } from "@hotwired/stimulus"

// Handles "select all" and delete confirmation for admin bulk-action tables.
export default class extends Controller {
  static targets = ["all", "item"]

  toggleAll() {
    this.itemTargets.forEach((cb) => (cb.checked = this.allTarget.checked))
  }

  confirm(event) {
    const selected = this.itemTargets.filter((cb) => cb.checked).length
    const action = this.element.querySelector("[name='bulk_action']").value

    if (selected === 0) {
      event.preventDefault()
      alert("Select at least one product first.")
      return
    }
    if (action === "delete" && !window.confirm(`Delete ${selected} product(s)? This cannot be undone.`)) {
      event.preventDefault()
    }
  }
}
