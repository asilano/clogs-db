class MailingList < ActiveRecord::Base
  attr_accessible :name, :member_ids
  validates_presence_of :name
  validates_uniqueness_of :name, allow_nil: false
  has_and_belongs_to_many :members
end
