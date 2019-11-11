import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "search", "database", "goodreads", "openlibrary", "withoutCovers" ]

  initialize() {
    // Hide flash on page back
    if (performance.navigation.type == 2) {
      const flash = document.querySelector('div.notification.is-warning');
      if (flash) {
        flash.style.display = 'none';
      }
    }
    this.searchTarget.parentNode.classList.remove("is-loading");
    document.addEventListener("keydown", this.search.bind(this));
  }


  changeTab(e) {
    document.querySelectorAll(".panel-tabs .tab").forEach(tab => {
      tab.classList.remove("is-active");
    });
    e.currentTarget.classList.add("is-active");
    const selectedTab = e.currentTarget.dataset['value'];
    this.searchTarget.placeholder = `Search by ${selectedTab}...`;
  }

  toggleAdvanced() {
    this.withoutCoversTarget.parentNode.classList.toggle("is-hidden");
  }

  search(e) {
    if(e.keyCode == 13) {
      const searchValue = this.searchTarget.value.trim();
      if (searchValue.length == 0) { return; }
      // `is-loading` class goes on the input field container
      this.searchTarget.parentNode.classList.add("is-loading");
      const searchType = document.querySelector('.panel-tabs .tab.is-active').dataset['value'];
      let searchPath = this.withoutCoversTarget.checked ? "/books?without_covers=true&" : "/books?"

      if (this.databaseTarget.checked) {
        return window.location = `${searchPath}${searchType}=${searchValue}`
        // return window.location = `/books?${searchType}=${searchValue}`;
      } else if (this.goodreadsTarget.checked) {
        return window.location = `${searchPath}${searchType}=${searchValue}&source=goodreads`
        // return window.location = `/books?${searchType}=${searchValue}&source=goodreads`;
      } else if (this.openlibraryTarget.checked) {
        return window.location = `${searchPath}${searchType}=${searchValue}&source=openlibrary`
        // return window.location = `/books?${searchType}=${searchValue}&source=openlibrary`;
      }
    }
  }
}
