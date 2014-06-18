require 'spec_helper'

describe Member do
  it "habtm mailing lists" do
    expect(subject).to have_and_belong_to_many :mailing_lists
  end
end
