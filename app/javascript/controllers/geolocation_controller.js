import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['latitude', 'longitude'];

  connect() {
  }

  geolocate() {
    if (!navigator.geolocation) {
      console.error('Geolocation is not supported in this browser.');
      return;
    }

    // Check current permission state
    if (navigator.permissions && navigator.permissions.query) {
      navigator.permissions.query({ name: 'geolocation' }).then((result) => {
        console.log('Geolocation permission state:', result.state);
        
        if (result.state === 'denied') {
          console.log('Location permission was denied. Please enable location permissions in your browser settings.');
          // Show user-friendly message about enabling permissions
          this.showPermissionMessage();
        } else {
          // Request location
          this.requestLocation();
        }
      }).catch(() => {
        // Fallback if permissions API not supported
        this.requestLocation();
      });
    } else {
      // Fallback for older browsers
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
        maximumAge: 0 // Don't use cached position
      }
    );
  }

  showPermissionMessage() {
    // Create or update a user-friendly message
    const message = 'Location access was previously denied. Please enable location permissions in your browser settings and refresh the page.';
    console.log(message);
    
    // You could also update the UI here to show this message
    const searchContainer = document.querySelector('.search-bar-container');
    if (searchContainer) {
      const existingMessage = searchContainer.querySelector('.geolocation-message');
      if (existingMessage) {
        existingMessage.remove();
      }
      
      const messageDiv = document.createElement('div');
      messageDiv.className = 'geolocation-message';
      messageDiv.style.cssText = 'color: #dc3545; font-size: 0.875rem; margin-top: 0.5rem; text-align: center;';
      messageDiv.textContent = message;
      searchContainer.appendChild(messageDiv);
      
      // Remove message after 10 seconds
      setTimeout(() => {
        messageDiv.remove();
      }, 10000);
    }
  }

  success(position) {
    this.latitudeTarget.value = `${position.coords.latitude.toFixed(6)}`;
    this.longitudeTarget.value = `${position.coords.longitude.toFixed(6)}`;
  }

  error(error) {
    console.error('Geolocation error:', error);
    
    let userMessage = '';
    switch(error.code) {
      case 1: // PERMISSION_DENIED
        userMessage = 'Location access denied. Please enable location permissions in your browser settings and refresh the page.';
        this.showPermissionMessage();
        break;
      case 2: // POSITION_UNAVAILABLE
        userMessage = 'Location unavailable. Please check your device location settings.';
        break;
      case 3: // TIMEOUT
        userMessage = 'Location request timed out. Please try again.';
        break;
      default:
        userMessage = 'Location request failed. Please try again.';
    }
    
    console.log(userMessage);
  }
}
