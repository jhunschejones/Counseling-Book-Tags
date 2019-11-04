import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "forgotPassword" ]

  initialize() {
    this.forgotPasswordTarget.addEventListener("click", () => {
      document.getElementById("password-reset-link").click();
    });
  }
}
