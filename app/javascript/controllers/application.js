import { Application } from '@hotwired/stimulus'

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus = application

export { application }

export { newSlideMenu }

function newSlideMenu() {
  var slide_menu = document.querySelectorAll('.sidenav')
  M.Sidenav.init(slide_menu, {
    edge: 'left',
  })
}
newSlideMenu()
