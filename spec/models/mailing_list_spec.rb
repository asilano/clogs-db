require 'spec_helper'

describe MailingList do
  describe "validations" do
    it "validates presence of name" do
      expect(subject).to validate_presence_of :name
    end

    it "validates uniqueness of name" do
      FactoryBot.create(:mailing_list)
      expect(subject).to validate_uniqueness_of :name
    end
  end

  it "habtm members" do
    expect(subject).to have_and_belong_to_many :members
  end
end
