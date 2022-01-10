import { Controller } from '@hotwired/stimulus'
import Sortable from 'sortablejs'
export default class extends Controller {
  connect () {
    this.sortable = Sortable.create(this.element, {
      animation: 150
    })
  }
}
