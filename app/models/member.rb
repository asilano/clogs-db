class Member < ActiveRecord::Base
  attr_accessible :addr1, :addr2, :addr3, :concert_fee_paid, :county, :email, :forename, :membership, :mobile,
                  :phone, :postcode, :show_fee_paid, :subs_paid, :surname, :town, :voice,
                  :mailing_list_ids, :notes, :join_year
  has_and_belongs_to_many :mailing_lists

  scope :name_order, -> { order('surname, forename') }

  def fullname
    "#{forename} #{surname}"
  end

  def address
    [addr1, addr2, addr3, town, county, postcode].reject(&:blank?).join("\n")
  end

  def formatted_phone
    UKPhoneNumbers.format(phone.andand.gsub(/\s/, '')).andand.gsub(/\s/, '&nbsp;') || phone
  end

  def formatted_mobile
    UKPhoneNumbers.format(mobile.andand.gsub(/\s/, '')).andand.gsub(/\s/, '&nbsp;') || mobile
  end

  def mailing_list_names
    mailing_lists.map(&:name).sort.join(', ')
  end

  # Search pseudo-fields
  ransacker :full_name do |parent|
    Arel::Nodes::NamedFunction.new('concat_ws',
      [' ', parent.table[:forename], parent.table[:surname]])
  end

  ransacker :address do |parent|
    Arel::Nodes::NamedFunction.new('concat_ws', [', ', *([:addr1, :addr2, :addr3, :town, :county, :postcode].map { |col| parent.table[col] })])
  end

  def self.ransackable_attributes(auth_object = nil)
    all = super - ['id', 'created_at', 'updated_at']
    all.delete 'full_name'
    all.delete 'address'

    all.insert(all.index('forename'), 'full_name')
    all.insert(all.index('addr1'), 'address')
  end
end
