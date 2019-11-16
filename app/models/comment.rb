class Comment < ApplicationRecord
  include ActionView::Helpers::JavaScriptHelper
  belongs_to :user
  belongs_to :book
  before_save :sanitize_body

  def success_response
    {
      data: {
        id: self.id,
        type: "comment",
        attributes: {
          body: self.html_safe_body,
          createdAt: self.created_at.localtime.to_formatted_s(:long_ordinal),
        },
        relationships: {
          user: { data: { id: self.user.id, type: "user", attributes: { name: self.user.name, }, } }
        }
      }
    }
  end

  def html_safe_body
    # escape javascript but allow safe quotes and paragraph breaks
    self.body = escape_javascript(self.body.gsub(/\n{2,}/, "<br /><br />"))
      .gsub("\\'", "'")
      .gsub("\\\"", "\"")
  end

  private
    def sanitize_body
      # remove trailing spaces and html tags
      self.body = self.body.strip.gsub(/<\/?\w*\s?\/?>/, "")
    end
end
