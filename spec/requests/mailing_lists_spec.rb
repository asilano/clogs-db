require 'spec_helper'

describe "MailingLists" do
  describe "while logged out" do
    describe "GET /mailing_lists" do
      it "redirects to login path" do
        get mailing_lists_path
        expect(response.status).to be(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "POST /mailing_lists" do
      it "redirects to login path" do
        post mailing_lists_path, {name: 'John\'s list'}
        expect(response.status).to be(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "GET /mailing_lists/new" do
      it "redirects to login path" do
        get new_mailing_list_path
        expect(response.status).to be(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "GET /mailing_lists/:id/edit" do
      it "redirects to login path" do
        mailing_list = FactoryGirl.create(:mailing_list)
        get edit_mailing_list_path(mailing_list)
        expect(response.status).to be(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "GET /mailing_lists/:id" do
      it "redirects to login path" do
        mailing_list = FactoryGirl.create(:mailing_list)
        get mailing_list_path(mailing_list)
        expect(response.status).to be(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "PUT /mailing_lists/:id" do
      it "redirects to login path" do
        mailing_list = FactoryGirl.create(:mailing_list)
        put mailing_list_path(mailing_list), {name: 'Jane\'s list'}
        expect(response.status).to be(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "DELETE /mailing_lists/:id" do
      it "redirects to login path" do
        mailing_list = FactoryGirl.create(:mailing_list)
        delete mailing_list_path(mailing_list)
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
    end

    describe "GET /mailing_lists" do
      it "displays tabbed navigation" do
        visit mailing_lists_path
        expect(page).to have_css('.tab a', text: 'Members')
        expect(page).to have_css('.tab.current a', text: 'Mailing lists')
      end

      it "displays all mailing_lists" do
        visit mailing_lists_path

        # A selection of headings
        expect(page).to have_css('th', text: "Name")
        expect(page).to have_css('td', text: @mailing_list.name)
        expect(page).to have_css('td', text: @sub_list.name)
      end
    end

    describe "GET show" do
      it "displays tabbed navigation" do
        visit mailing_list_path(@mailing_list.id)
        expect(page).to have_css('.tab.current span', text: 'View mailing list')
        expect(page).to have_css('.tab a', text: 'Members')
        expect(page).to have_css('.tab a', text: 'Mailing lists')
      end

      it "displays the requested mailing_list" do
        visit mailing_list_path(@mailing_list.id)

        # A selection of headings
        expect(page).to have_css('th', text: "Name")
        expect(page).to have_css('td', text: @mailing_list.name)
        expect(page).to_not have_css('td', text: @sub_list.name)

        visit mailing_list_path(@sub_list.id)
        expect(page).to have_css('td', text: @sub_list.name)
        expect(page).to_not have_css('td', text: @mailing_list.name)
      end
    end

    describe "create mailing_list through form" do
      it "displays tabbed navigation" do
        visit new_mailing_list_path
        expect(page).to have_css('.tab.current span', text: 'New mailing list')
        expect(page).to have_css('.tab a', text: 'Members')
        expect(page).to have_css('.tab a', text: 'Mailing lists')
      end

      it "creates the mailing_list with valid params" do
        max_id = MailingList.select(:id).order('id desc').first[:id]
        visit mailing_lists_path
        page.first('a', text: 'New Mailing list').click

        fill_in 'Name', with: 'Basses only'
        click_button 'Save'

        expect(current_path).to eq mailing_list_path(max_id + 1)
        expect(MailingList.last.name).to eq 'Basses only'
        expect(page).to have_content('Basses only')
      end

      describe "redisplays the create form with invalid params" do
        it "rejects absent name" do
          visit mailing_lists_path
          page.first('a', text: 'New Mailing list').click

          fill_in 'Name', with: ''
          click_button 'Save'

          expect(page).to have_content('Name can\'t be blank')
          expect(page).to have_css('label', text: 'Name')
        end

        it "rejects duplicate name" do
          visit mailing_lists_path
          page.first('a', text: 'New Mailing list').click

          fill_in 'Name', with: @mailing_list.name
          click_button 'Save'

          expect(page).to have_content('Name has already been taken')
          expect(page).to have_css('label', text: 'Name')
        end
      end
    end

    describe "edit mailing_list through form" do
      it "displays tabbed navigation" do
        visit edit_mailing_list_path(@mailing_list.id)
        expect(page).to have_css('.tab.current span', text: 'Edit mailing list')
        expect(page).to have_css('.tab a', text: 'Members')
        expect(page).to have_css('.tab a', text: 'Mailing lists')
      end

      it "updates the mailing_list with valid params" do
        visit mailing_list_path(@sub_list)
        click_link 'Edit'

        expect(page).to have_field('Name')
        fill_in 'Name', with: 'Tenors only'
        click_button 'Save'

        expect(current_path).to eq mailing_list_path(@sub_list)
        expect(@sub_list.reload.name).to eq 'Tenors only'
        expect(page).to have_content('Tenors only')
      end

      describe "redisplays the edit form with invalid params" do
        it "rejects absent name" do
          visit edit_mailing_list_path(@sub_list.id)

          fill_in 'Name', with: ''
          click_button 'Save'

          expect(page).to have_content('Name can\'t be blank')
          expect(page).to have_css('label', text: 'Name')
        end

        it "rejects duplicate name" do
          visit edit_mailing_list_path(@sub_list.id)

          fill_in 'Name', with: @mailing_list.name
          click_button 'Save'

          expect(page).to have_content('Name has already been taken')
          expect(page).to have_css('label', text: 'Name')
        end
      end
    end

    describe "DELETE destroy" do
      it "destroys the requested mailing_list" do
        visit mailing_lists_path
        old_name = @mailing_list.name
        expect {
          page.first('a span.icon-remove').find(:xpath, '..').click
        }.to change(MailingList, :count).by(-1)

        expect(MailingList.where { name == old_name }.first).to be_nil
        expect(current_path).to eq mailing_lists_path
      end
    end
  end
end
