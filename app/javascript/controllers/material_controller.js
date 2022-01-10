import { Controller } from '@hotwired/stimulus'

// https://github.com/material-components/material-components-web/blob/master/docs/importing-js.md
import {MDCList} from '@material/list'

const list = new MDCList(document.querySelector('.mdc-deprecated-list'))
export default class extends Controller {
  connect () {
    this.list = MDCList.create(this.element, {
      animation: 150
    })
  }
}
