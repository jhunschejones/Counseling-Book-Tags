class Book < ApplicationRecord
  has_many :tags, dependent: :destroy
  validates :title, :authors, :isbn, :published_year, :source, presence: true
end
