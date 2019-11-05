import { Controller } from "stimulus"

export default class extends Controller {
  changeTab(e) {
    // remove currently active tab
    document.querySelectorAll(".tabs .tab").forEach(tab => {
      tab.classList.remove("is-active");
    });
    // make new tab active
    e.currentTarget.classList.add("is-active");
    // remove currently active tab content
    document.querySelectorAll(".tab-content").forEach(tabContent => {
      tabContent.classList.remove("is-active");
    });
    // make new tab content active
    document.querySelectorAll(
      `.tab-content.${e.currentTarget.dataset.tab}`)[0].classList.add("is-active");
  }
}
