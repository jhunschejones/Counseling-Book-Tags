class User < ApplicationRecord
  has_secure_password
  has_many :tags, dependent: :destroy
  validates :name, :email, :password_digest, presence: true
  validates :email, uniqueness: true
end
