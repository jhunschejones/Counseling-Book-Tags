class Book < ApplicationRecord
  has_many :tags, dependent: :destroy
  validates :title, :author, :isbn, :published_year, presence: true
end
