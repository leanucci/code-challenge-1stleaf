require 'rails_helper'

RSpec.describe User, type: :model do
  subject { FactoryBot.create(:user) }
  describe "validations" do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:phone_number) }
    it { should validate_presence_of(:key) }

    it { should validate_uniqueness_of(:email).ignoring_case_sensitivity }
    it { should validate_uniqueness_of(:phone_number).ignoring_case_sensitivity }
    it { should validate_uniqueness_of(:account_key).ignoring_case_sensitivity }

    it "requires unique key" do
      duplicate = FactoryBot.create(:user)
      duplicate.key = subject.key
      expect(duplicate.save).to be_falsey
      expect(duplicate.errors.full_messages).to eq(["Key has already been taken"])
    end
  end

  describe "on creation" do
    it "enqueues an account key request job" do
      expect(AccountKeyJob).to receive(:perform_later).once
      FactoryBot.create(:user)
    end
  end
end
