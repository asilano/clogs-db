# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :member do
    forename "MyString"
    surname "MyString"
    addr1 "MyString"
    addr2 "MyString"
    addr3 "MyString"
    town "MyString"
    county "MyString"
    postcode "MyString"
    phone "MyString"
    mobile "MyString"
    voice "MyString"
    membership "MyString"
    email "MyString"
    subs_paid false
    show_fee_paid false
    concert_fee_paid false
  end
end
