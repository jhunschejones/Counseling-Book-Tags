class Tag < ApplicationRecord
  belongs_to :user
  belongs_to :book
  validates :text, :user, :book, presence: true
  before_save :title_case
  NON_CAPITALIZED_WORDS = ["a", "an", "and", "at", "but", "by", "for", "from", "in", "is", "nor", "on", "or", "the", "to"].freeze

  def self.uniques_from_list_of_books(books)
    books.map { |book| book.tags }.flatten.uniq { |tag| tag.text }
  end

  def title_case
    self.text = self.text.downcase.split.map.with_index do |word, index|
      if index == 0 || !NON_CAPITALIZED_WORDS.include?(word)
        word.capitalize
      else
        word
      end
    end.join(" ")
  end
end
