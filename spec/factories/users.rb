FactoryBot.define do
  sequence(:user_email) { |n| "user-#{n}@example.com" }

  factory :user do
    email { generate(:user_email) }
    phone_number { Faker::PhoneNumber.cell_phone_in_e164 }
    password { 'supersafe' }
    full_name { Faker::Name.unique.name }
    metadata { Faker::Types.rb_array(len: 5, type: -> { Faker::Types.rb_string }) }
  end
end

__END__

| Field Name   | Properties                                                |
| ------------ | --------------------------------------------------------- |
| id           | integer, primary key, not null, unique, auto-incrementing |
| email        | string, max 200 characters, not null, unique              |
| phone_number | string, max 20 characters, not null, unique               |
| full_name    | string, max 200 characters                                |
| password     | string, max 100 characters, not null                      |
| key          | string, max 100 characters, not null, unique              |
| account_key  | string, max 100 characters, unique                        |
| metadata     | string, max 2000 characters                               |
