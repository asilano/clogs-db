class Member < ActiveRecord::Base
  attr_accessible :addr1, :addr2, :addr3, :concert_fee_paid, :county, :email, :forename, :membership, :mobile,
                  :phone, :postcode, :show_fee_paid, :subs_paid, :surname, :town, :voice,
                  :mailing_list_ids, :notes
  has_and_belongs_to_many :mailing_lists

  scope :name_order, -> { order('surname, forename') }

  def fullname
    "#{forename} #{surname}"
  end

  def address
    [addr1, addr2, addr3, town, county, postcode].reject(&:blank?).join("\n")
  end

  def formatted_phone
    UKPhoneNumbers.format(phone.andand.gsub(/\s/, '')).andand.gsub(/\s/, '&nbsp;') || ''
  end

  def formatted_mobile
    UKPhoneNumbers.format(mobile.andand.gsub(/\s/, '')).andand.gsub(/\s/, '&nbsp;') || ''
  end

  def mailing_list_names
    mailing_lists.map(&:name).join(', ')
  end
end
