import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["latitude", "longitude"];

  connect() {
    this.geolocate()
  }

  geolocate() {
    if (!navigator.geolocation) {
      this.latitudeTarget.textContent = "Geolocation is not supported in this browser.";
    } else {
      navigator.geolocation.getCurrentPosition(
        this.success.bind(this),
        this.error.bind(this)
      );
    }
  }

  success(position) {
    let latitude = 36.91;
    let longitude = -79.99;

    this.latitudeTarget.value = `${position.coords.latitude.toFixed(
      2
    )}`;
    this.longitudeTarget.value = `${position.coords.longitude.toFixed(
      2
    )}`;

    // let latitude = 36.91;
    // let longitude = -79.99;

    return [latitude, longitude];
  }

  error(error) {
    console.log(error);
    this.latitudeTarget.textContent = "check the console log for error";  // error.message
  }
}