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

      @member1 = FactoryGirl.create(:member, forename: 'John', surname: 'Smith', email: 'j.smith@example.com')
      @member2 = FactoryGirl.create(:member, forename: 'Jane', surname: 'Doe', email: 'janed@example.com')
      @member3 = FactoryGirl.create(:member, forename: 'Bob', surname: 'Patron', email: 'patronb@example.com')

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
        expect(page).to have_field :subject
        expect(page).to have_field :body
      end

      it "should be accessible via Mailing List index" do
        visit mailing_lists_path
        page.first('a .icon-envelope').find(:xpath, '..').click
        expect(page).to have_select(:mailing_list_id, selected: MailingList.first.name)
        expect(page).to have_field :subject
        expect(page).to have_field :body
      end

      it "should be accessible via Mailing List show page" do
        visit mailing_list_path(@sub_list)
        click_link 'Email this list'
        expect(page).to have_select(:mailing_list_id, selected: @sub_list.name)
        expect(page).to have_field :subject
        expect(page).to have_field :body
      end

    end

    describe "create mail shot" do
      before :each do
        reset_email
      end

      it "should create a delayed job" do
        visit new_mail_shot_path(mailing_list_id: @sub_list)
        fill_in :subject, with: "Test email"
        fill_in :body, with: "Hello,\n\nThis is a test email."

        expect { click_button 'Send' }.to change { Delayed::Job.count }.by 1

        expect(last_email).to be_nil
      end

      it "should send emails when the job happens" do
        subject = "Test email"
        body = "Hello,\n\nThis is a test email."

        visit new_mail_shot_path
        select @sub_list.name, from: 'Mailing list'
        fill_in :subject, with: subject
        fill_in :body, with: body
        click_button 'Send'

        expect(Delayed::Worker.new.work_off).to eq [1, 0]
        expect(all_emails.count).to eq @sub_list.members.count

        @sub_list.members.zip(all_emails) do |row|
          member = row[0]
          email = row[1]
          expect(email.to).to eq [member.email]
          expect(email.subject).to eq subject
          expect(email.body).to eq body
        end
      end

      it "should allow mail-merge fields"

      it "should ignore wrong mail-merge fields"

      it "should error if mailing list is absent"

      it "should error if mailing list is non-existent"

      it "should error if body is absent"

      it "should warn about members with no email address" do
        @member1.email = nil
        @member2.email = 'fake-email'
        @member1.save
        @member2.save

        visit new_mail_shot_path(mailing_list_id: @mailing_list)
        fill_in :subject, with: "Test email"
        fill_in :body, with: "Hello,\n\nThis is a test email."
        click_button "Send"

        expect(page).to have_content('The following members will not be emailed, as they do not have a configured email address')
        expect(page).to have_css('li', text: @member1.fullname)
        expect(page).to have_css('li', text: @member2.fullname)
      end

      it "should ignore members with no email address" do
        @member1.email = nil
        @member2.email = "fake-emil"
        @member1.save
        @member2.save

        visit new_mail_shot_path(mailing_list_id: @mailing_list)
        fill_in :subject, with: "Test email"
        fill_in :body, with: "Hello,\n\nThis is a test email."
        click_button "Send"

        expect(Delayed::Worker.new.work_off).to eq [1, 0]
        expect(all_emails.count).to eq @mailing_list.members.count - 2

        @mailing_list.members.reject { |m| m == @member1 || m == @member2 }.zip(all_emails) do |row|
          member = row[0]
          email = row[1]
          expect(email.to).to eq [member.email]
          expect(email.subject).to eq 'Test email'
          expect(email.body).to eq "Hello,\n\nThis is a test email."
        end
      end
    end
  end
end