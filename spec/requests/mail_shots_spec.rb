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
      footer = "

----
This is the mailing list of CLOGS Musical Theatre, Chippenham.
If you wish to unsubscribe from this list, or to have your details removed from our database entirely, please reply to this email."

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
      @simple_dynamic_list = FactoryGirl.create(:simple_dynamic_list)
      @complex_dynamic_list = FactoryGirl.create(:complex_dynamic_list)

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
        expect(page).to have_css('.tab.current a', text: 'Mail Shot')
      end

      it "should be accessible via Mailing List index" do
        visit mailing_lists_path
        page.first('a .icon-envelope').find(:xpath, '..').click
        expect(page).to have_select(:mailing_list_id, selected: MailingList.first.name)
        expect(page).to have_field :subject
        expect(page).to have_field :body
        expect(page).to have_css('.tab.current a', text: 'Mail Shot')
      end

      it "should be accessible via Mailing List show page" do
        visit mailing_list_path(@sub_list)
        click_link 'Email this list'
        expect(page).to have_select(:mailing_list_id, selected: @sub_list.name)
        expect(page).to have_field :subject
        expect(page).to have_field :body
        expect(page).to have_css('.tab.current a', text: 'Mail Shot')
      end

      it "should be accessible via tabbed navigation" do
        visit root_path
        expect(page).to have_css('.tab a', text: 'Mail Shot')
        click_link 'Mail Shot'
        expect(page).to have_select :mailing_list_id
        expect(page).to have_field :subject
        expect(page).to have_field :body
        expect(page).to have_css('.tab.current a', text: 'Mail Shot')
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
          expect(email.body).to eq (body + footer)
        end
      end

      it "should resolve the mailing list's dynamic query" do
        # We'll need a number of Members for this test, with varying information that matches - or not - the
        # defined queries. We'll be working with "<forename or email> CONTAINS 'ian'" and
        # "<membership> EQUALS 'Life Patron' OR (<membership> EQUALS 'Patron' AND <subs_paid> EQUALS 'true'"
        details = [
          {forename: 'Ian', surname: 'Rankin', email: 'ir@example.com'},
          {forename: 'John', surname: 'Smith', email: 'js.ians.mate@example.com'},
          {forename: 'Bob', surname: 'Roberts', membership: 'Patron', subs_paid: true, email: 'bob@example.com'},
          {forename: 'Jane', surname: 'Ian', email:'jane@example.com'},
          {forename: 'Brian', surname: 'Cox', membership: 'Life Patron', email: 'coxy@example.com'},
          {forename: 'Ian', surname: 'Duncan-Smith', email: 'iands@example.com'},
          {forename: 'Ernie', surname: 'Wise', membership: 'Patron', subs_paid: false, email: 'him@example.com'},
          {forename: 'Julianos', surname: 'the Wise', email: 'deity@example.com'}
        ]
        Member.destroy_all
        members = details.map { |member| Member.create member }
        expect(Member.count).to eq details.size

        subject = "Test email"
        body = "Hello,\n\nThis is a test email."

        visit new_mail_shot_path
        select @simple_dynamic_list.name, from: 'Mailing list'
        fill_in :subject, with: subject
        fill_in :body, with: body
        click_button 'Send'

        # Check we email all the Ians in forename and email. Expect case insensitivity
        matching = [0, 1, 4, 5, 7].map { |n| members[n] }
        expect(Delayed::Worker.new.work_off).to eq [1, 0]
        expect(all_emails.count).to eq matching.count

        matching.zip(all_emails) do |row|
          member = row[0]
          email = row[1]
          expect(email.to).to eq [member.email]
          expect(email.subject).to eq subject
          expect(email.body).to eq (body + footer)
        end

        # Now check we email the patrons
        ActionMailer::Base.deliveries.clear
        visit new_mail_shot_path
        select @complex_dynamic_list.name, from: 'Mailing list'
        fill_in :subject, with: subject
        fill_in :body, with: body
        click_button 'Send'
        matching = [2, 4].map { |n| members[n] }
        expect(Delayed::Worker.new.work_off).to eq [1, 0]
        expect(all_emails.count).to eq matching.count

        matching.zip(all_emails) do |row|
          member = row[0]
          email = row[1]
          expect(email.to).to eq [member.email]
          expect(email.subject).to eq subject
          expect(email.body).to eq (body + footer)
        end

        # Test list with fixed and dynamic members
        @simple_dynamic_list.members = Member.where { surname.like_any ['Rankin', 'Roberts', '%Wise'] }
        @simple_dynamic_list.save

        # Varying members and fixed members are emailed, only once each
        ActionMailer::Base.deliveries.clear
        visit new_mail_shot_path
        select @simple_dynamic_list.name, from: 'Mailing list'
        fill_in :subject, with: subject
        fill_in :body, with: body
        click_button 'Send'
        matching = [0, 1, 2, 4, 5, 6, 7].map { |n| [members[n].email] }
        expect(Delayed::Worker.new.work_off).to eq [1, 0]
        expect(all_emails.count).to eq matching.count
        expect(all_emails.map(&:to)).to match_array(matching)
      end

      it "should error if body is absent" do
        visit new_mail_shot_path
        select @sub_list.name, from: 'Mailing list'
        fill_in :subject, with: "Test subject"
        fill_in :body, with: ''

        expect { click_button 'Send' }.to_not change { Delayed::Job.count }
        expect(page).to have_css('#flash .error', text: "Mail shot is missing its body")
      end

      it "should error if subject is absent" do
        visit new_mail_shot_path
        select @sub_list.name, from: 'Mailing list'
        fill_in :subject, with: ''
        fill_in :body, with: 'Test body'

        expect { click_button 'Send' }.to_not change { Delayed::Job.count }
        expect(page).to have_css('#flash .error', text: "Mail shot is missing its subject")
      end

      it "should give both errors if subject and body are absent" do
        visit new_mail_shot_path
        select @sub_list.name, from: 'Mailing list'
        fill_in :subject, with: ''
        fill_in :body, with: ''

        expect { click_button 'Send' }.to_not change { Delayed::Job.count }
        expect(page).to have_css('#flash .error', text: "Mail shot is missing its subject")
        expect(page).to have_css('#flash .error', text: "Mail shot is missing its body")
      end

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

      it "should warn about dynamic members with no email address" do
        details = [
          {forename: 'Ian', surname: 'Rankin', email: 'ir@example.com'},
          {forename: 'John', surname: 'Smith', email: 'js.ians.mate@example.com'},
          {forename: 'Bob', surname: 'Roberts', membership: 'Patron', subs_paid: true, email: 'bob@example.com'},
          {forename: 'Jane', surname: 'Ian', email:'jane@example.com'},
          {forename: 'Brian', surname: 'Cox', membership: 'Life Patron', email: 'coxy@example.com'},
          {forename: 'Ian', surname: 'Duncan-Smith', email: 'fake-email'},
          {forename: 'Ernie', surname: 'Wise', membership: 'Patron', subs_paid: false, email: 'him@example.com'},
          {forename: 'Julianos', surname: 'the Wise', email: nil}
        ]
        Member.destroy_all
        members = details.map { |member| Member.create member }
        expect(Member.count).to eq details.size

        subject = "Test email"
        body = "Hello,\n\nThis is a test email."

        visit new_mail_shot_path
        select @simple_dynamic_list.name, from: 'Mailing list'
        fill_in :subject, with: subject
        fill_in :body, with: body
        click_button 'Send'

        expect(page).to have_content('The following members will not be emailed, as they do not have a configured email address')
        expect(page).to have_css('li', text: 'Ian Duncan-Smith')
        expect(page).to have_css('li', text: 'Julianos the Wise')
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
          expect(email.body).to eq ("Hello,\n\nThis is a test email." + footer)
        end
      end

      it "should ignore dynamic members with no email address" do
        details = [
          {forename: 'Ian', surname: 'Rankin', email: 'ir@example.com'},
          {forename: 'John', surname: 'Smith', email: 'js.ians.mate@example.com'},
          {forename: 'Bob', surname: 'Roberts', membership: 'Patron', subs_paid: true, email: 'bob@example.com'},
          {forename: 'Jane', surname: 'Ian', email:'jane@example.com'},
          {forename: 'Brian', surname: 'Cox', membership: 'Life Patron', email: 'coxy@example.com'},
          {forename: 'Ian', surname: 'Duncan-Smith', email: 'fake-email'},
          {forename: 'Ernie', surname: 'Wise', membership: 'Patron', subs_paid: false, email: 'him@example.com'},
          {forename: 'Julianos', surname: 'the Wise', email: nil}
        ]
        Member.destroy_all
        members = details.map { |member| Member.create member }
        expect(Member.count).to eq details.size

        subject = "Test email"
        body = "Hello,\n\nThis is a test email."

        visit new_mail_shot_path
        select @simple_dynamic_list.name, from: 'Mailing list'
        fill_in :subject, with: subject
        fill_in :body, with: body
        click_button 'Send'

        # Pick up the matching members with email addresses
        matching = [0, 1, 4].map { |n| members[n] }
        expect(Delayed::Worker.new.work_off).to eq [1, 0]
        expect(all_emails.count).to eq matching.count

        matching.zip(all_emails) do |row|
          member = row[0]
          email = row[1]
          expect(email.to).to eq [member.email]
          expect(email.subject).to eq subject
          expect(email.body).to eq (body + footer)
        end
      end
    end

    describe 'mail-merge' do
      before :each do
        reset_email
      end

      it "should perform simple mail-merge" do
        subject = "Test email"
        body = "Hello <forename>,\n\nThis is a test email."

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
          expect(email.body).to eq (body.sub(/<forename>/, member.forename) + footer)
        end
      end

      it "should merge all mergable fields" do
        @mailing_list.members = [@member1]
        @mailing_list.save
        subject = 'Test email'
        body = <<EOD
<forename>
<surname>
<fullname>
<addr1>
<addr2>
<addr3>
<town>
<county>
<postcode>
<address>
<phone>
<mobile>
<voice>
<membership>
<email>
<subs_paid>
<show_fee_paid>
<concert_fee_paid>
<mailing_list_names>
<notes>
EOD
        expected_body = <<EOD
John
Smith
John Smith
123 High Street
Second Floor
Office 2
Chippenham
Wiltshire
SN1 1NS
123 High Street
Second Floor
Office 2
Chippenham
Wiltshire
SN1 1NS
01249123456
07777123456
Tenor
Performing
j.smith@example.com
true
false
true
Only some members, Publicity
Married to Jane


----
This is the mailing list of CLOGS Musical Theatre, Chippenham.
If you wish to unsubscribe from this list, or to have your details removed from our database entirely, please reply to this email.
EOD
        visit new_mail_shot_path
        select @mailing_list.name, from: 'Mailing list'
        fill_in :subject, with: subject
        fill_in :body, with: body
        click_button 'Send'

        expect(Delayed::Worker.new.work_off).to eq [1, 0]
        expect(last_email.body).to eq expected_body.chomp
      end

      it "should ignore wrong mail-merge fields" do
        subject = "Test email"
        body = "Hello <forename>,\n\nThis is a <test> email."

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
          expect(email.body).to include "<test>"
        end
      end
    end

    describe 'attachments' do
      before :each do
        reset_email
      end

      let(:files) { %w<file1.txt file2.png file3.xml>.map { |fn| Rails.root.join("spec/data/#{fn}") } }
      let(:badFiles) { %w<absentFile1 absentFile2>.map { |fn| Rails.root.join("spec/data/#{fn}") } }

      it "should allow a single attachment to be chosen" do
        visit new_mail_shot_path(mailing_list_id: @sub_list)
        fill_in :subject, with: "Test email"
        fill_in :body, with: "Hello,\n\nThis is a test email."
        attach_file 'Attach files', files[0]
        click_button 'Send'

        expect(page).to have_content 'Emails created, and queued for delivery.'
      end

      it "should allow multiple attachements to be chosen" do
        pending 'Capybara support for multiple uploads'
      end

      it "should include a single attachment in queued job" do
        visit new_mail_shot_path(mailing_list_id: @sub_list)
        fill_in :subject, with: "Test email"
        fill_in :body, with: "Hello,\n\nThis is a test email."
        attach_file 'Attach files', files[0]

        expect { click_button 'Send' }.to change { Delayed::Job.count }.from(0).to(1)
        expect(Delayed::Job.first.handler.scan('!ruby/struct:MailShot::Attachment').count).to eq 1
      end

      it "should include multiple attachments in queued job" do
        pending 'Capybara support for multiple uploads'
      end

      it "should send single attachment" do
        visit new_mail_shot_path(mailing_list_id: @sub_list)
        fill_in :subject, with: "Test email"
        fill_in :body, with: "Hello,\n\nThis is a test email."
        attach_file 'Attach files', files[0]
        click_button 'Send'

        expect(Delayed::Worker.new.work_off).to eq [1, 0]
        expect(all_emails.count).to eq @sub_list.members.count

        @sub_list.members.zip(all_emails) do |row|
          member = row[0]
          email = row[1]
          expect(email.to).to eq [member.email]
          expect(email.subject).to eq 'Test email'
          expect(email.text_part.body).to include "Hello,\n\nThis is a test email."
          expect(email.attachments).to have(1).file
          att = email.attachments[0]
          expect(att.filename).to eq File.basename files[0]
          expect(att.body.decoded).to eq File.read files[0]
        end
      end

      it "should send multiple attachments" do
        pending 'Capybara support for multiple uploads'
      end

      it "should error if single attachment is unavailable"

      it "should error on all unavailable attachments" do
        pending 'Capybara support for multiple uploads'
      end
    end
  end
end