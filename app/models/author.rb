class Author < ApplicationRecord
  has_and_belongs_to_many :books
  validates :name, presence: true
  before_create :set_name_keywords
  NOT_KEYWORDS = ["AND", "THE", "OR", "OF", "A"].freeze

  def self.name_keywords(name)
    # remove non-word, non-space characters
    name.gsub(/[^\w\s]/, "").upcase.split.map do |word|
      word = word.strip
      if NOT_KEYWORDS.include?(word) || !word.present?
        nil
      else
        word
      end
    end.compact.uniq
  end

  private
    def set_name_keywords
      self.name_keywords = Author.name_keywords(self.name)
    end
end
