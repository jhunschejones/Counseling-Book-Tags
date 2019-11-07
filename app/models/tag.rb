class Tag < ApplicationRecord
  belongs_to :user
  belongs_to :book
  validates :text, :user, :book, presence: true

  def self.uniques_from_list_of_books(books)
    books.map { |book| book.tags }.flatten.uniq { |tag| tag.text }
  end
end
