import { Controller } from "stimulus"

export default class extends Controller {
  initialize() {
    document.querySelector(".tags-container").addEventListener("ajax:success", this.deleteTag.bind(this));
    document.querySelector(".comments-container").addEventListener("ajax:success", this.deleteComment.bind(this));
  }

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

  deleteTag(e) {
    const data = e.detail[0];
    const status = e.detail[1];
    const xhr = e.detail[2];

    if (status === "No Content") {
      const deletedTagId = xhr["responseURL"].split("tags/")[1];
      const deletedTag = document.querySelector(`div[data-tag-id="${deletedTagId}"]`);
      deletedTag.parentElement.removeChild(deletedTag);
    }
  }

  deleteComment(e) {
    const data = e.detail[0];
    const status = e.detail[1];
    const xhr = e.detail[2];

    if (status === "No Content") {
      const deletedCommentId = xhr["responseURL"].split("comments/")[1];
      const deletedComment = document.querySelector(`div.comment[data-comment-id="${deletedCommentId}"]`);
      deletedComment.parentElement.removeChild(deletedComment);
    }
  }
}
