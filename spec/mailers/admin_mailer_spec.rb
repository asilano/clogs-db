require "spec_helper"

describe AdminMailer do
  describe "approval_needed" do
    let(:user) { FactoryGirl.create(:user) }
    let(:mail) { AdminMailer.approval_needed(user) }

    it "renders the headers" do
      expect(mail.subject).to eq "User wants approval for Clogs Members"
      expect(mail.to).to eq ["foo@example.com"]
      expect(mail.from).to eq ["foo@example.com"]
    end

    it "renders the body" do
      expect(mail.body.encoded).to match(user.email)
    end
  end

end
