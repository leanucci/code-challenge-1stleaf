class User < ApplicationRecord
  has_secure_password
  before_validation :generate_credentials, on: :create

  validates :email, presence: true, length: { maximum: 200 }
  validates_uniqueness_of :email, case_sensitive: false

  validates :phone_number, presence: true, length: { maximum: 20 }
  validates_uniqueness_of :phone_number, case_sensitive: false

  validates :key, presence: true, length: { maximum: 100 }
  validates_uniqueness_of :key, case_sensitive: false

  validates_uniqueness_of :account_key, allow_blank: true, case_sensitive: false
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
