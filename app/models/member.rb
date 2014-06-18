class Member < ActiveRecord::Base
  attr_accessible :addr1, :addr2, :addr3, :concert_fee_paid, :county, :email, :forename, :membership, :mobile,
                  :phone, :postcode, :show_fee_paid, :subs_paid, :surname, :town, :voice
  has_and_belongs_to_many :mailing_lists
end
