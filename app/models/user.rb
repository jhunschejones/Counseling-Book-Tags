class User < ApplicationRecord
  has_secure_password
  has_many :tags, dependent: :destroy
  validates :name, :email, :password_digest, presence: true
  validates :email, uniqueness: true

  def generate_password_reset_token!
    self.reset_password_token = SecureRandom.hex(10)
    self.reset_password_sent_at = Time.now.utc
    save!
   end

   def generate_email_verification_token!
    self.email_verification_token = SecureRandom.hex(10)
    self.email_verification_sent_at = Time.now.utc
    save!
   end

   def password_token_valid?
    (self.reset_password_sent_at + 4.hours) > Time.now.utc
   end

   def reset_password!(password)
    self.is_verified = true
    self.email_verification_token = nil
    self.reset_password_token = nil
    self.password = password
    save!
   end

   def verify_email!
    self.is_verified = true
    self.email_verification_token = nil
    save!
   end
end
