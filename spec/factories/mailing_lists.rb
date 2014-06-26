# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mailing_list do
    name "Publicity"
  end

  factory :small_mailing_list, :class => MailingList do
    name "Only some members"
  end
end
