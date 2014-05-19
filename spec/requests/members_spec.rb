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
        post members_path, {forename: 'John'}
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
        member = FactoryGirl.create(:member)
        get edit_member_path(member)
        expect(response.status).to be(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "GET /members/:id" do
      it "redirects to login path" do
        member = FactoryGirl.create(:member)
        get member_path(member)
        expect(response.status).to be(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "PUT /members/:id" do
      it "redirects to login path" do
        member = FactoryGirl.create(:member)
        put member_path(member), {forename: 'Jane'}
        expect(response.status).to be(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "DELETE /members/:id" do
      it "redirects to login path" do
        member = FactoryGirl.create(:member)
        delete member_path(member)
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
      @member = FactoryGirl.create(:member)
      @wife = FactoryGirl.create(:members_wife)
    end

    describe "GET /members" do
      it "displays all members" do
        visit members_path

        # A selection of headings
        expect(page).to have_css('th', text: "Forename")
        expect(page).to have_css('th', text: "Voice")
        expect(page).to have_css('th', text: "Concert paid")

        # A selection of fields for the first member
        expect(page).to have_css('td', text: @member.surname)
        expect(page).to have_css('td', text: @member.membership)
        expect(page).to have_css('td', text: @member.mobile)

        # A selection of fields for the second member
        expect(page).to have_css('td', text: @wife.forename)
        expect(page).to have_css('td', text: @wife.membership)
        expect(page).to have_css('td', text: @wife.email)
      end
    end

    describe "GET show" do
      it "displays the requested member" do
        visit member_path(@member.id)

        # A selection of headings
        expect(page).to have_css('th', text: "Surname")
        expect(page).to have_css('th', text: "Membership")
        expect(page).to have_css('th', text: "Subs paid")

        # A selection of fields for the first member
        expect(page).to have_css('td', text: @member.forename)
        expect(page).to have_css('td', text: @member.email)
        expect(page).to have_css('td', text: @member.addr1)
        expect(page).to_not have_css('td', text: @wife.forename)

        visit member_path(@wife.id)
        # A selection of fields for the second member
        expect(page).to have_css('td', text: @wife.forename)
        expect(page).to have_css('td', text: @wife.email)
        expect(page).to have_css('td', text: @wife.addr1)
        expect(page).to_not have_css('td', text: @member.forename)
      end
    end

    describe "create member through form" do
      it "creates the member with valid params" do
        max_id = Member.select(:id).order('id desc').first[:id]
        visit members_path
        page.first('a', text: 'New Member').click

        fill_in 'Forename', with: 'Bob'
        fill_in 'Surname', with: 'Roberts'
        click_button 'Save'

        expect(current_path).to eq member_path(max_id + 1)
        expect(Member.last.forename).to eq 'Bob'
        expect(page).to have_content('Roberts')
      end

      it "redisplays the create form with invalid params" do
        pending "Validations on Member"
      end
    end

    describe "edit member through form" do
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
      end
    end

    describe "DELETE destroy" do
      it "destroys the requested member" do
        visit members_path
        old_forename = @member.forename
        expect {
          page.first('a', text: 'Destroy').click
        }.to change(Member, :count).by(-1)

        expect(Member.where{ forename == old_forename }.first).to be_nil
        expect(current_path).to eq members_path
      end
    end
  end
end
