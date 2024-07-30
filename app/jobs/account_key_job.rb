class UnstableExternalApiError < StandardError; end
class AccountKeyJob < ApplicationJob
  include HTTParty
  queue_as :default
  retry_on UnstableExternalApiError, wait: 5.minutes

  # TODO: move url to env var
  ACCOUNT_SERVICE_URI = 'https://w7nbdj3b3nsy3uycjqd7bmuplq0yejgw.lambda-url.us-east-2.on.aws/v1/account'

  def perform(user_id)
    begin
      user = User.find(user_id)

      return if user.account_key.present?
      body = {
        email: user.email,
        key: user.key
      }
      response = HTTParty.post(ACCOUNT_SERVICE_URI, body: JSON.generate(body), headers: { 'Content-Type' => 'application/json'})

      if response.success?
        user.update_attribute(:account_key, response['account_key'])
      else
        raise UnstableExternalApiError
      end
    rescue ActiveRecord::RecordNotFound
      # log user id #{user_id} no longer exists, no need to retry
      false
    end
  end
end
