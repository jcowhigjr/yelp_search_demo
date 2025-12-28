import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['latitude', 'longitude'];

  connect() {
  }

  geolocate() {
    if (!navigator.geolocation) {
      this.latitudeTarget.textContent =
        'Geolocation is not supported in this browser.';
    } else {
      navigator.geolocation.getCurrentPosition(
        this.success.bind(this),
        this.error.bind(this)
      );
    }
  }

  success(position) {
    this.latitudeTarget.value = `${position.coords.latitude.toFixed(6)}`;
    this.longitudeTarget.value = `${position.coords.longitude.toFixed(6)}`;
  }

  error(error) {
    console.error('Geolocation error:', error);
    // Show user-friendly error message
    const errorMessage = error.code === 1 ? 
      'Location access denied. Please enable location permissions.' :
      error.code === 2 ? 
      'Location unavailable. Please check your device settings.' :
      'Location request timed out. Please try again.';
    
    console.log(errorMessage);
  }
}
