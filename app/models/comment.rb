class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :book

  def successfully_created_response
    {
      data: {
        id: self.id,
        type: "comment",
        attributes: {
          body: self.body,
          createdAt: self.created_at.localtime.to_formatted_s(:long_ordinal),
        },
        relationships: {
          user: { data: { id: self.user.id, type: "user", attributes: { name: self.user.name, }, } }
        }
      }
    }
  end
end
