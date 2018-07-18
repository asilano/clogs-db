class MailingList < ActiveRecord::Base
  serialize :query, Hash

  validates :name, presence: true, uniqueness: true
  has_and_belongs_to_many :members

  def self.ransackable_attributes(auth_object = nil)
    ['name']
  end

end
