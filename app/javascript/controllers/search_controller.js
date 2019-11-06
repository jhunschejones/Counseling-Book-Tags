import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "searchInput", "searchButton", "select", "spacer" ]

  initialize() {
    this.searchButtonTarget.classList.remove("is-loading");
    document.querySelector(".search-container input").addEventListener("keydown", (e) => {
      if(e.keyCode == 13) {
        this.search();
      }
    });
  }

  search() {
    if (this.searchInputTarget.value.trim().length > 0) {
      this.searchButtonTarget.classList.add("is-loading");
      return window.location = `/books?${this.selectTarget.value}=${this.searchInputTarget.value.trim()}&source=goodreads`;
    }
  }
}
