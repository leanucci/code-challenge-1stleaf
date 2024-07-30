require 'rails_helper'

RSpec.describe "/api/users", type: :request do
  # This should return the minimal set of attributes required to create a valid
  # User. As you add validations to User, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {
      full_name: 'Some Name',
      email: 'user-special@example.com',
      phone_number: '0303456',
      metadata: ['unemployed, hitman'],
      password: 'mellon',
      password_confirmation: 'mellon'
    }
  }

  let(:invalid_attributes) {
    {
      full_name: 'Some Name',
      email: 'user-special@example.com',
      phone_number: '0303456',
      metadata: 'unemployed, hitman',
    }

  }

  let(:parsed_response) { JSON.parse(response.body) }
  describe "GET /index" do
    before do
      FactoryBot.create_list(:user, 10)
    end

    describe "without query params" do
      it "renders a successful response" do
        get api_users_url, as: :json
        expect(response).to be_successful
        expect(parsed_response.count).to eq(User.count)
        expect(parsed_response.first['email']).to eq User.last.email
      end
    end

    describe "with valid query params" do
      it "renders a successful response" do
        # get "/api/users?full_name=#{User.first.full_name}", as: :json
        get "/api/users?full_name=#{User.first.full_name}", as: :json
        expect(response).to be_successful
        expect(parsed_response.count).to be < User.count
        expect(parsed_response.first['full_name']).to eq User.first.full_name
      end
    end

    describe "with invalid query params" do
      it "renders a successful response" do
        get "/api/users?name=will-fail", as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      user = User.create! valid_attributes
      get api_user_url(user), as: :json
      expected_body = {
        "email" => "user-special@example.com",
        "phone_number" => "0303456",
        "full_name" => "Some Name",
        "key" => user.key,
        "account_key" => nil,
        "metadata" => ["unemployed, hitman"]
      }
      expect(parsed_response).to include(expected_body)
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new User" do
        expect {
          post api_users_url,
               params: { user: valid_attributes }, as: :json
        }.to change(User, :count).by(1)
      end

      it "renders a JSON response with the new user" do
        post api_users_url,
             params: { user: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "does not create a new User" do
        expect {
          post api_users_url,
               params: { user: invalid_attributes }, as: :json
        }.to change(User, :count).by(0)
      end

      it "renders a JSON response with errors for the new user" do
        post api_users_url,
             params: { user: invalid_attributes }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
        expect(parsed_response).to include("password")
      end
    end
  end
end
