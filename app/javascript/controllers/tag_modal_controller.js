import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "modal" ]

  initialize() {
    document.querySelector(".tag-modal").addEventListener("ajax:success", this.createTagInDOM.bind(this));
  }

  open() {
    this.modalTarget.classList.add("is-active");
    document.getElementsByTagName("html")[0].classList.add("is-clipped");
    document.addEventListener("click", this.clickAway.bind(this));
  }

  close() {
    this.modalTarget.classList.remove("is-active");
    document.getElementsByTagName("html")[0].classList.remove("is-clipped");
  }

  clickAway(e) {
    if (e.target.classList.contains("modal-background")) {
      document.removeEventListener("click", this.clickAway.bind(this));
      this.close();
    }
  }

  createTagInDOM(e) {
    const data = e.detail[0];
    const status = e.detail[1];
    const xhr = e.detail[2];
    if (!data["errors"]) {
      data["data"].forEach(newTag => {
        document.querySelector(".tags-container").appendChild(this.stringToNode(
          `<div class="control" data-tag-id="${newTag["id"]}">
            <div class="tags has-addons">
              <a class="tag is-info is-medium">${newTag["attributes"]["text"]}</a>
              <a class="tag is-delete is-info is-medium" data-remote="true" rel="nofollow" data-method="delete" href="/tags/${newTag["id"]}" data-confirm="Are you sure you want to delete the '${newTag["attributes"]["text"]}' tag?"></a>
            </div>
          </div>`
        ));
      });
    }
    this.close();
  }

    /**
   * Convert an HTML string into a DOM node to append to the page
   * @param  {string} html html to convert into a DOM node
   */
  stringToNode(html) {
    const template = document.createElement('template');
    template.innerHTML = html;
    return template.content.firstChild;
  }
}
