require 'spec_helper'

describe 'MailShots' do
  describe "while logged out" do
    describe "GET new" do
      it "redirects to login" do
        get new_mail_shot_path
        expect(response.status).to be(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "POST create" do
      it "redirects to login" do
        post mail_shots_path, { mailing_list_id: 1, body: "Hello" }
        expect(response.status).to be(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "while logged in" do
    let(:user) { FactoryGirl.create(:user) }
    before(:each) do
      visit new_user_session_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign in'
    end

    describe "access creation page" do
      it "should be accessible directly" do
        visit new_mail_shot_path
        expect(page).to have_field :mailing_list_id
        expect(page).to have_field :body
      end

      it "should be accessible via Mailing List index" do
        visit mailing_lists_path
        page.first('a .icon-envelope').click
        expect(page).to have_field :mailing_list_id
        expect(page).to have_field :body
      end

      it "should be accessible via Mailing List show page"

    end

    describe "create mail shot" do
      it "should create a delayed job"

      it "should send emails when the job happens"

      it "should allow mail-merge fields"

      it "should ignore wrong mail-merge fields"

      it "should error if mailing list is absent"

      it "should error if mailing list is non-existent"

      it "should error if body is absent"
    end
  end
end