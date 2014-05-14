require 'spec_helper'

describe "Members" do
  describe "while logged in" do
    let(:user) { FactoryGirl.create(:user) }
    before(:each) { post_via_redirect user_session_path, 'user[email]' => user.email, 'user[password]' => user.password }

    describe "GET /members" do
      it "works! (now write some real specs)" do
        get members_path
        expect(response.status).to be(200)
      end
    end
  end
end
