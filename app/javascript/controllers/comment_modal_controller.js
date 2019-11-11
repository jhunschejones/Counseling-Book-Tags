import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "newModal", "editModal", "submitButton", "updateButton" ]

  initialize() {
    document.querySelector(".comment-modal").addEventListener("ajax:success", this.handlePostResponse.bind(this));
    document.querySelector(".edit-comment-modal").addEventListener("ajax:success", this.handlePutResponse.bind(this));
  }

  openCreate() {
    this.newModalTarget.classList.add("is-active");
    document.getElementsByTagName("html")[0].classList.add("is-clipped");
    document.addEventListener("click", this.clickAway.bind(this));
  }

  closeCreate() {
    this.newModalTarget.classList.remove("is-active");
    document.getElementsByTagName("html")[0].classList.remove("is-clipped");
  }

  openEdit(e) {
    this.editModalTarget.classList.add("is-active");
    document.getElementsByTagName("html")[0].classList.add("is-clipped");
    document.addEventListener("click", this.clickAway.bind(this));

    // set text area value for editing
    const commentId = e.currentTarget.dataset["commentId"];
    const commentBody = document.querySelector(`div[data-comment-id="${commentId}"] .comment-body`).innerText;
    document.querySelector(".edit-comment-input").value = commentBody;

    // set correct comment id in link href
    const postLink = decodeURI(document.querySelector(".edit-comment-button .button").href);
    document.querySelector(".edit-comment-button .button").href = postLink.replace(/\/comments\/\d*\?/, `/comments/${commentId}?`);
  }

  updatePutBody() {
    const newBodyContent = `[body]=${document.querySelector(".edit-comment-input").value}&`;
    document.querySelector(".edit-comment-button .button").href = decodeURI(document.querySelector(".edit-comment-button .button").href).replace(/\[body\]=.*&/, encodeURI(newBodyContent));
  }

  closeEdit() {
    this.editModalTarget.classList.remove("is-active");
    document.getElementsByTagName("html")[0].classList.remove("is-clipped");
  }

  clickAway(e) {
    if (e.target.classList.contains("modal-background")) {
      document.removeEventListener("click", this.clickAway.bind(this));
      this.closeCreate();
      this.closeEdit();
    }
  }

  submit() {
    this.submitButtonTarget.classList.add("is-loading");
  }

  update() {
    this.updateButtonTarget.classList.add("is-loading");
  }

  handlePostResponse(e) {
    const data = e.detail[0];
    const status = e.detail[1];
    const xhr = e.detail[2];
    if (!data["errors"]) {
      document.querySelector(".comments-container").appendChild(this.stringToNode(
        `<div class="box comment" data-comment-id="${data["data"]["id"]}">
          <article class="media">
            <div class="media-content">
              <div class="content">
                <p>
                  <strong>${data["data"]["relationships"]["user"]["data"]["attributes"]["name"]}</strong>&nbsp;-&nbsp;
                  <small>${data["data"]["attributes"]["createdAt"]}</small>
                  <br />
                  "<span class="comment-body">${data["data"]["attributes"]["body"]}</span>"
                </p>
              </div>
                <nav class="level">
                  <div class="level-left"></div>
                  <div class="level-right">
                    <a class="level-item edit-comment-button" data-comment-id="${data["data"]["id"]}" data-action="click->comment-modal#openEdit">
                      <span class="icon">
                        <i class="fas fa-edit"></i>
                      </span>
                    </a>
                    <a class="level-item delete-comment-button" data-confirm="Are you sure you want to delete your comment?" data-remote="true" rel="nofollow" data-method="delete" href="/comments/${data["data"]["id"]}">
                      <span class="icon">
                        <i class="fas fa-trash"></i>
                      </span>
                    </a>
                  </div>
                </nav>
            </div>
          </article>
        </div>`
      ));
    }
    this.submitButtonTarget.classList.remove("is-loading");
    document.querySelector(".comment-input").value = "";
    this.closeCreate();
  }

  handlePutResponse(e) {
    const data = e.detail[0];
    const status = e.detail[1];
    const xhr = e.detail[2];
    if (status === "OK") {
      const commentId = decodeURI(xhr.responseURL).match(/^.*\/comments\/(\d*)?.*$/)[1];
      const newCommentBody = decodeURI(xhr.responseURL).match(/^.*\[body\]=(.*)&comment.*$/)[1];
      document.querySelector(`div[data-comment-id="${commentId}"] .comment-body`).innerText = newCommentBody;
    }
    this.updateButtonTarget.classList.remove("is-loading");
    document.querySelector(".edit-comment-input").value = "";
    this.closeEdit();
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
