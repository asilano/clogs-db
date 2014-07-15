# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :member do
    forename "John"
    surname "Smith"
    addr1 "123 High Street"
    addr2 ""
    addr3 ""
    town "Chippenham"
    county "Wiltshire"
    postcode "SN1 1NS"
    phone "01249123456"
    mobile "07777123456"
    voice "Tenor"
    membership "Performing"
    email "j.smith@example.com"
    subs_paid true
    show_fee_paid false
    concert_fee_paid true

    after(:create) {|member| member.mailing_lists = [MailingList.first || create(:mailing_list)]}
  end

  factory :members_wife, parent: :member do
    forename 'Jane'
    mobile ''
    voice 'Soprano'
    membership 'Non-Performing'
    concert_fee_paid false

    after(:create) {|wife| wife.mailing_lists << create(:small_mailing_list)}
  end
end
