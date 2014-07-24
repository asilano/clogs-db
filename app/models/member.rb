class Member < ActiveRecord::Base
  attr_accessible :addr1, :addr2, :addr3, :concert_fee_paid, :county, :email, :forename, :membership, :mobile,
                  :phone, :postcode, :show_fee_paid, :subs_paid, :surname, :town, :voice,
                  :mailing_list_ids
  has_and_belongs_to_many :mailing_lists

  scope :name_order, -> { order('surname, forename') }

  def fullname
    "#{forename} #{surname}"
  end
end
