import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['latitude', 'longitude'];

  connect() {
    // Try to get location on page load if we have permission
    this.initializeLocation();
  }

  initializeLocation() {
    // Check if we have previously stored location
    const storedLocation = this.getStoredLocation();
    if (storedLocation) {
      this.updateLocationInputs(storedLocation.latitude, storedLocation.longitude);
      return;
    }

    // Check if geolocation is supported
    if (!navigator.geolocation) {
      this.showError('Geolocation is not supported in this browser.');
      return;
    }

    // Try to get current position without prompting user
    // This will only work if permission was already granted
    navigator.geolocation.getCurrentPosition(
      this.success.bind(this),
      (error) => {
        // Silently fail on initialization - user can click button to trigger prompt
        console.log('Geolocation not available on page load:', error.message);
      },
      { timeout: 1000, maximumAge: 300000 } // 5 minute cache, 1 second timeout
    );
  }

  geolocate() {
    if (!navigator.geolocation) {
      this.showError('Geolocation is not supported in this browser.');
      return;
    }

    // Show loading state
    this.showLoading();

    navigator.geolocation.getCurrentPosition(
      this.success.bind(this),
      this.error.bind(this),
      { timeout: 10000, maximumAge: 300000 } // 5 minute cache, 10 second timeout
    );
  }

  success(position) {
    const latitude = position.coords.latitude;
    const longitude = position.coords.longitude;

    // Update form inputs
    this.updateLocationInputs(latitude, longitude);

    // Store for future use
    this.storeLocation(latitude, longitude);

    // Clear any error messages
    this.clearMessages();

    // Optional: trigger a change event to let other parts of the app know
    this.latitudeTarget.dispatchEvent(new Event('change', { bubbles: true }));
    this.longitudeTarget.dispatchEvent(new Event('change', { bubbles: true }));
  }

  error(error) {
    let message = 'Unable to get your location.';

    switch (error.code) {
      case error.PERMISSION_DENIED:
        message = 'Location access denied. Please enable location permissions.';
        break;
      case error.POSITION_UNAVAILABLE:
        message = 'Location information unavailable.';
        break;
      case error.TIMEOUT:
        message = 'Location request timed out.';
        break;
    }

    this.showError(message);
    console.error('Geolocation error:', error);
  }

  updateLocationInputs(latitude, longitude) {
    this.latitudeTarget.value = latitude.toFixed(6);
    this.longitudeTarget.value = longitude.toFixed(6);
  }

  storeLocation(latitude, longitude) {
    try {
      localStorage.setItem('userLocation', JSON.stringify({
        latitude,
        longitude,
        timestamp: Date.now()
      }));
    } catch (e) {
      console.warn('Could not store location:', e);
    }
  }

  getStoredLocation() {
    try {
      const stored = localStorage.getItem('userLocation');
      if (!stored) return null;

      const location = JSON.parse(stored);
      // Use stored location if less than 1 hour old
      if (Date.now() - location.timestamp < 3600000) {
        return location;
      }
    } catch (e) {
      console.warn('Could not retrieve stored location:', e);
    }
    return null;
  }

  showLoading() {
    // You could add a loading state to the button here
    const button = this.element.querySelector('button[data-action*="geolocate"]');
    if (button) {
      button.disabled = true;
      button.innerHTML = '<i class="material-icons">hourglass_empty</i>';
    }
  }

  showError(message) {
    // Remove any existing error messages
    this.clearMessages();

    // Create error message element
    const errorDiv = document.createElement('div');
    errorDiv.className = 'geolocation-error text-red-500 text-sm mt-1';
    errorDiv.textContent = message;

    // Insert after the geolocation div
    this.element.parentNode.insertBefore(errorDiv, this.element.nextSibling);

    // Auto-remove after 5 seconds
    setTimeout(() => {
      if (errorDiv.parentNode) {
        errorDiv.parentNode.removeChild(errorDiv);
      }
    }, 5000);

    // Reset button state
    this.resetButton();
  }

  clearMessages() {
    const existingError = this.element.parentNode.querySelector('.geolocation-error');
    if (existingError) {
      existingError.parentNode.removeChild(existingError);
    }
  }

  resetButton() {
    const button = this.element.querySelector('button[data-action*="geolocate"]');
    if (button) {
      button.disabled = false;
      button.innerHTML = '<i class="material-icons">my_location</i>';
    }
  }
}
