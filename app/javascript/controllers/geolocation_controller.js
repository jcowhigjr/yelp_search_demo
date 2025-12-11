import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['latitude', 'longitude'];

  connect() {
    this.geolocate();
  }

  geolocate() {
    if (!navigator.geolocation) {
      console.warn('Geolocation is not supported in this browser.');
      return;
    }

    navigator.geolocation.getCurrentPosition(
      this.success.bind(this),
      this.error.bind(this)
    );
  }

  success(position) {
    this.latitudeTarget.value = position.coords.latitude.toFixed(2);
    this.longitudeTarget.value = position.coords.longitude.toFixed(2);
  }

  error(error) {
    console.warn('Geolocation error:', error.message);
  }
}
