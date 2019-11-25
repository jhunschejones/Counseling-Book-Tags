class Author < ApplicationRecord
  has_and_belongs_to_many :books
  validates :name, presence: true
  before_create :set_name_keywords
  IGNORED_KEYWORDS = ["AND", "THE", "OR", "OF", "A"].freeze

  def self.name_keywords(name)
    name
      .gsub(/[^\w\s]/, "") # remove non-word, non-space characters
      .upcase
      .split
      .select { |word| word.present? && !IGNORED_KEYWORDS.include?(word) }
      .uniq
  end

  private
    def set_name_keywords
      self.name_keywords = Author.name_keywords(self.name)
    end
end
