# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "person_#{n}@example.com" }
    password 'secret'
    approved true
  end
end
