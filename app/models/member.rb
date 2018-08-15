class Member < ApplicationRecord
  extend FriendlyId
  friendly_id :fullname, use: :slugged

  has_and_belongs_to_many :mailing_lists

  validates :surname, :forename, presence: true

  scope :name_order, -> { order('surname, forename') }

  after_validation :move_friendly_id_error_to_name

  def move_friendly_id_error_to_name
    errors.add :name, *errors.delete(:friendly_id) if errors[:friendly_id].present?
  end

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
      [Arel::Nodes.build_quoted(' '), parent.table[:forename], parent.table[:surname]])
  end

  ransacker :address do |parent|
    Arel::Nodes::NamedFunction.new('concat_ws',
                                   [Arel::Nodes.build_quoted(', '),
                                    *([:addr1,
                                       :addr2,
                                       :addr3,
                                       :town,
                                       :county,
                                       :postcode].map { |col| parent.table[col] })])
  end

  def self.ransackable_attributes(auth_object = nil)
    all = super - ['id', 'created_at', 'updated_at']
    all.delete 'full_name'
    all.delete 'address'

    all.insert(all.index('forename'), 'full_name')
    all.insert(all.index('addr1'), 'address')
  end
end
