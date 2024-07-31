class User < ApplicationRecord
  has_secure_password
  before_validation :generate_credentials, on: :create

  validates :email, presence: true, length: { maximum: 200 }, uniqueness: true
  validates :phone_number, presence: true, length: { maximum: 20 }, uniqueness: true
  validates :key, presence: true, length: { maximum: 100 }
  validates_uniqueness_of :key
  validates_uniqueness_of :account_key, allow_blank: true
  validates :metadata, length: { maximum: 2000 }

  private

  def generate_credentials
    # this key size needs 17 years generating 1k keys an hour to have 1% chance of collision...
    begin
      self.key = SecureRandom.hex(20)
    end while self.class.exists?(key: key)

    request_account_key
  end

  def request_account_key
    AccountKeyJob.perform_later(self.id)
  end
end
