require "spec_helper"

describe AdminMailer do
  describe "approval_needed" do
    let(:user) { FactoryGirl.create(user) }
    let(:mail) { Admin.approval_needed(user) }

    it "renders the headers" do
      mail.subject.should eq("User wants approval for Clogs Members")
      mail.to.should eq(["chowlett09@gmail.com"])
      mail.from.should eq(["chowlett09@gmail.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match(user.email)
    end
  end

end
