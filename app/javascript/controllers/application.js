import { Application } from "@hotwired/stimulus"
import '@material/mwc-list'
import '@material/mwc-button'
import '@polymer/paper-button'
import '@fortawesome/fontawesome-free'
import 'fg-modal'

const application = Application.start()

// Configure Stimulus development experience
application.warnings = true
application.debug    = true
window.Stimulus      = application

export { application }
