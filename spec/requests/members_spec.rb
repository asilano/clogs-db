require 'spec_helper'

describe "Members" do
  describe "while logged out" do
    describe "GET /members" do
      it "redirects to login path" do
        get members_path
        expect(response.status).to be(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "POST /members" do
      it "redirects to login path" do
        post members_path, params: { forename: 'John' }
        expect(response.status).to be(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "GET /members/new" do
      it "redirects to login path" do
        get new_member_path
        expect(response.status).to be(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "GET /members/:id/edit" do
      it "redirects to login path" do
        member = FactoryBot.create(:member)
        get edit_member_path(member)
        expect(response.status).to be(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "GET /members/:id" do
      it "redirects to login path" do
        member = FactoryBot.create(:member)
        get member_path(member)
        expect(response.status).to be(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "PUT /members/:id" do
      it "redirects to login path" do
        member = FactoryBot.create(:member)
        put member_path(member), params: { forename: 'Jane' }
        expect(response.status).to be(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "DELETE /members/:id" do
      it "redirects to login path" do
        member = FactoryBot.create(:member)
        delete member_path(member)
        expect(response.status).to be(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "while logged in" do
    let(:user) { FactoryBot.create(:user) }
    before(:each) do
      visit new_user_session_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign in'
    end

    before(:each) do
      @list_one = FactoryBot.create(:mailing_list, name: 'First list')
      @list_two = FactoryBot.create(:mailing_list, name: 'Second list')
      @list_three = FactoryBot.create(:mailing_list, name: 'Third list')
      @member = FactoryBot.create(:member)
      @wife = FactoryBot.create(:members_wife)
    end

    describe "GET /members" do
      it "displays tabbed navigation" do
        visit members_path
        expect(page).to have_css('.tab.current a', text: 'Members')
        expect(page).to have_css('.tab a', text: 'Mailing lists')
      end

      it "displays all members" do
        visit members_path

        # A selection of headings
        expect(page).to have_css('th', text: "Forename")
        expect(page).to have_css('th', text: "Voice")
        expect(page).to have_css('th', text: "Concert paid")
        expect(page).to have_css('th', text: "Notes")

        # A selection of fields for the first member
        expect(page).to have_css('td', text: @member.surname)
        expect(page).to have_css('td', text: @member.membership)
        expect(page).to have_css('td', text: @member.formatted_mobile.sub('&nbsp;', ' '))

        # A selection of fields for the second member
        expect(page).to have_css('td', text: @wife.forename)
        expect(page).to have_css('td', text: @wife.membership)
        expect(page).to have_css('td', text: @wife.email)
        expect(page).to have_css('td', text: @wife.notes)
      end
    end

    describe "GET show" do
      it "displays tabbed navigation" do
        visit member_path(@member.id)
        expect(page).to have_css('.tab.current span', text: 'View member')
        expect(page).to have_css('.tab a', text: 'Members')
        expect(page).to have_css('.tab a', text: 'Mailing lists')
      end

      it "displays the requested member" do
        visit member_path(@member.id)

        # A selection of headings
        expect(page).to have_css('th', text: "Surname")
        expect(page).to have_css('th', text: "Membership")
        expect(page).to have_css('th', text: "Subs paid")
        expect(page).to have_css('th', text: "Mailing lists")

        # A selection of fields for the first member
        expect(page).to have_css('td', text: @member.forename)
        expect(page).to have_css('td', text: @member.email)
        expect(page).to have_css('td', text: @member.addr1)
        icon = @member.concert_fee_paid ? 'checkmark' : 'cross'
        expect(page).to have_css("td span.icon-#{icon}")
        @member.mailing_lists.each do |list|
          expect(page).to have_css('td a', text: list.name)
        end
        expect(page).to have_css('td', text: @member.notes)

        expect(page).to_not have_css('td', text: @wife.voice)

        visit member_path(@wife.id)
        # A selection of fields for the second member
        expect(page).to have_css('td', text: @wife.forename)
        expect(page).to have_css('td', text: @wife.email)
        expect(page).to have_css('td', text: @wife.addr1)
        @wife.mailing_lists.each do |list|
          expect(page).to have_css('td a', text: list.name)
        end

        expect(page).to_not have_css('td', text: @member.voice)
      end

      it "links to each mailing list" do
        @wife.mailing_lists.each do |list|
          visit member_path(@wife.id)
          click_link list.name
          expect(current_path).to eq mailing_list_path(list)
        end
      end

      it "includes the currently-matching dynamic lists" do
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

        @simple_dynamic_list = FactoryBot.create(:simple_dynamic_list)   # Ians
        @complex_dynamic_list = FactoryBot.create(:complex_dynamic_list) # Patrons

        visit member_path(members[0].id)
        expect(page).to have_css('li a', text: @simple_dynamic_list.name)
        expect(page).to_not have_css('li a', text: @complex_dynamic_list.name)
        click_link @simple_dynamic_list.name
        expect(current_path).to eq mailing_list_path(@simple_dynamic_list)

        visit member_path(members[2].id)
        expect(page).to have_css('li a', text: @complex_dynamic_list.name)
        expect(page).to_not have_css('li a', text: @simple_dynamic_list.name)
        click_link @complex_dynamic_list.name
        expect(current_path).to eq mailing_list_path(@complex_dynamic_list)

        visit member_path(members[4].id)
        expect(page).to have_css('li a', text: @simple_dynamic_list.name)
        expect(page).to have_css('li a', text: @complex_dynamic_list.name)

        visit member_path(members[3].id)
        expect(page).to_not have_css('li a', text: @simple_dynamic_list.name)
        expect(page).to_not have_css('li a', text: @complex_dynamic_list.name)
        expect(page).to_not have_content('Currently matches the query')
      end
    end

    describe "create member through form" do
      it "displays tabbed navigation" do
        visit new_member_path
        expect(page).to have_css('.tab.current span', text: 'New member')
        expect(page).to have_css('.tab a', text: 'Members')
        expect(page).to have_css('.tab a', text: 'Mailing lists')
      end

      it "creates the member with valid params" do
        max_id = Member.select(:id).order('id desc').first[:id]

        visit members_path
        page.first('a', text: 'New Member').click

        fill_in 'Forename', with: 'Bob'
        fill_in 'Surname', with: 'Roberts'
        check(@list_one.name)
        check(@list_three.name)
        fill_in 'Notes', with: 'My uncle'
        click_button 'Save'

        expect(current_path).to eq member_path('bob-roberts')
        expect(Member.last.id).to eq (max_id + 1)
        expect(Member.last.forename).to eq 'Bob'
        expect(Member.last.mailing_lists.map(&:name)).to match_array [@list_one.name, @list_three.name]
        expect(page).to have_content('Roberts')
        expect(page).to have_content('My uncle')
        expect(page).to have_content(@list_three.name)
        expect(page).to_not have_content(@list_two.name)
      end

      it "redisplays the create form with invalid params" do
        pending "Validations on Member"
        fail
      end
    end

    describe "edit member through form" do
      it "displays tabbed navigation" do
        visit edit_member_path(@member.id)
        expect(page).to have_css('.tab.current span', text: 'Edit member')
        expect(page).to have_css('.tab a', text: 'Members')
        expect(page).to have_css('.tab a', text: 'Mailing lists')
      end

      it "updates the member with valid params" do
        visit member_path(@wife)
        click_link 'Edit'

        expect(page).to have_field('Forename')
        fill_in 'Voice', with: 'Bass'
        click_button 'Save'

        expect(current_path).to eq member_path(@wife)
        expect(@wife.reload.voice).to eq 'Bass'
        expect(page).to have_content('Bass')
      end

      it "redisplays the edit form with invalid params" do
        pending "validations on Member"
        fail
      end
    end

    describe "allows editing of paid-up fields from index" do
      it "without javascript" do
        visit members_path
        expect(page.all('a span.icon-cross').count).to eq 3

        page.find('tr', text: @member.voice).first('a span.icon-cross').first(:xpath, './/..').click

        expect(page.all('a span.icon-cross').count).to eq 2
        expect(Member.find(@member.id).subs_paid).to be true
        expect(Member.find(@member.id).show_fee_paid).to be true
        expect(Member.find(@member.id).concert_fee_paid).to be true
        expect(Member.find(@wife.id).subs_paid).to be true
        expect(Member.find(@wife.id).show_fee_paid).to be false
        expect(Member.find(@wife.id).concert_fee_paid).to be false
      end

      it "with javascript", js: true do
        visit members_path
        expect(page).to have_selector('a span.icon-cross', count: 3)

        page.find('tr', text: @member.voice).first('a span.icon-cross').first(:xpath, './/..').click

        expect(page).to have_selector('a span.icon-cross', count: 2)
        expect(Member.find(@member.id).subs_paid).to be true
        expect(Member.find(@member.id).show_fee_paid).to be true
        expect(Member.find(@member.id).concert_fee_paid).to be true
        expect(Member.find(@wife.id).subs_paid).to be true
        expect(Member.find(@wife.id).show_fee_paid).to be false
        expect(Member.find(@wife.id).concert_fee_paid).to be false
      end
    end

    describe "DELETE destroy" do
      it "destroys the requested member" do
        visit members_path
        old_forename = @member.forename
        expect {
          page.first('a span.icon-remove').find(:xpath, '..').click
        }.to change(Member, :count).by(-1)

        expect(Member.where.has { forename == old_forename }.first).to be_nil
        expect(current_path).to eq members_path
      end
    end
  end
end
