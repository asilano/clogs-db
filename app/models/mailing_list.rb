class MailingList < ActiveRecord::Base
  attr_accessible :name, :member_ids, :query
  serialize :query, Hash

  validates_presence_of :name
  validates_uniqueness_of :name, allow_nil: false
  has_and_belongs_to_many :members

  def self.ransackable_attributes(auth_object = nil)
    ['name']
  end

end
