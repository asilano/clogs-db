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
        post create_mail_shot_path, { mailing_list_id: 1, body: "Hello" }
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

    before(:each) do
      @mailing_list = FactoryGirl.create(:mailing_list)
      @sub_list = FactoryGirl.create(:small_mailing_list)
      @empty_list = FactoryGirl.create(:mailing_list, name: 'Empty List')

      @member1 = FactoryGirl.create(:member, forename: 'John', surname: 'Smith')
      @member2 = FactoryGirl.create(:member, forename: 'Jane', surname: 'Doe')
      @member3 = FactoryGirl.create(:member, forename: 'Bob', surname: 'Patron')

      @member1.mailing_lists = [@mailing_list, @sub_list]
      @member2.mailing_lists = [@mailing_list]
      @member3.mailing_lists = [@mailing_list, @sub_list]
      @member1.save!
      @member2.save!
      @member3.save!
    end

    describe "access creation page" do
      it "should be accessible directly" do
        visit new_mail_shot_path
        expect(page).to have_select :mailing_list_id
        expect(page).to have_field :body
      end

      it "should be accessible via Mailing List index" do
        visit mailing_lists_path
        page.first('a .icon-envelope').find(:xpath, '..').click
        expect(page).to have_select(:mailing_list_id, selected: MailingList.first.name)
        expect(page).to have_field :body
      end

      it "should be accessible via Mailing List show page" do
        visit mailing_list_path(@sub_list)
        click_link 'Email this list'
        expect(page).to have_select(:mailing_list_id, selected: @sub_list.name)
        expect(page).to have_field :body
      end

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