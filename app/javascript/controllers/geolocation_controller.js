import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['latitude', 'longitude', 'status'];

  connect() {
    this.geolocate();
  }

  geolocate() {
    this.updateStatus('requesting');

    if (!navigator.geolocation) {
      this.updateStatus('unavailable');
      return;
    }

    if (navigator.permissions && navigator.permissions.query) {
      navigator.permissions.query({ name: 'geolocation' }).then((result) => {
        if (result.state === 'denied') {
          this.updateStatus('denied');
        } else {
          this.requestLocation();
        }
      }).catch(() => {
        this.requestLocation();
      });
    } else {
      this.requestLocation();
    }
  }

  requestLocation() {
    navigator.geolocation.getCurrentPosition(
      this.success.bind(this),
      this.error.bind(this),
      {
        enableHighAccuracy: true,
        timeout: 10000,
        maximumAge: 0,
      }
    );
  }

  success(position) {
    this.latitudeTarget.value = `${position.coords.latitude.toFixed(6)}`;
    this.longitudeTarget.value = `${position.coords.longitude.toFixed(6)}`;
    this.updateStatus('success');
  }

  error(error) {
    switch(error.code) {
      case 1:
        this.updateStatus('denied');
        break;
      case 2:
      case 3:
        this.updateStatus('unavailable');
        break;
      default:
        this.updateStatus('unavailable');
    }
  }

  updateStatus(state) {
    if (!this.hasStatusTarget) {
      return;
    }

    const statusCopy = {
      idle: 'Checking location...',
      requesting: 'Requesting location...',
      success: 'Location ready',
      denied: 'Location blocked',
      unavailable: 'Location unavailable',
    };

    this.statusTarget.dataset.state = state;
    this.statusTarget.textContent = statusCopy[state] || statusCopy.unavailable;
  }
}
