require 'spec_helper'

describe "MailingLists" do
  describe "(while logged out)" do
    describe "GET /mailing_lists" do
      it "redirects to login path" do
        get mailing_lists_path
        expect(response.status).to be(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "POST /mailing_lists" do
      it "redirects to login path" do
        post mailing_lists_path, params: {name: 'John\'s list'}
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
        mailing_list = FactoryBot.create(:mailing_list)
        get edit_mailing_list_path(mailing_list)
        expect(response.status).to be(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "GET /mailing_lists/:id" do
      it "redirects to login path" do
        mailing_list = FactoryBot.create(:mailing_list)
        get mailing_list_path(mailing_list)
        expect(response.status).to be(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "PUT /mailing_lists/:id" do
      it "redirects to login path" do
        mailing_list = FactoryBot.create(:mailing_list)
        put mailing_list_path(mailing_list), params: {name: 'Jane\'s list'}
        expect(response.status).to be(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "DELETE /mailing_lists/:id" do
      it "redirects to login path" do
        mailing_list = FactoryBot.create(:mailing_list)
        delete mailing_list_path(mailing_list)
        expect(response.status).to be(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "(while logged in)" do
    let(:user) { FactoryBot.create(:user) }
    before(:each) do
      visit new_user_session_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign in'
    end

    before(:each) do
      @mailing_list = FactoryBot.create(:mailing_list)
      @sub_list = FactoryBot.create(:small_mailing_list)
      @empty_list = FactoryBot.create(:mailing_list, name: 'Empty List')
      @simple_dynamic_list = FactoryBot.create(:simple_dynamic_list)
      @complex_dynamic_list = FactoryBot.create(:complex_dynamic_list)
      @list_difference_list = FactoryBot.create(:list_difference)

      @member1 = FactoryBot.create(:member, forename: 'John', surname: 'Smith')
      @member2 = FactoryBot.create(:member, forename: 'Jane', surname: 'Doe')
      @member3 = FactoryBot.create(:member, forename: 'Bob', surname: 'Patron')

      @member1.mailing_lists = [@mailing_list, @sub_list]
      @member2.mailing_lists = [@mailing_list]
      @member3.mailing_lists = [@mailing_list, @sub_list]
      @member1.save!
      @member2.save!
      @member3.save!
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
        expect(page).to have_css('th', text: "Dynamic?")
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
        expect(page).to have_css('th', text: "Fixed members")
        expect(page.find 'tr', text: 'Varying members').to have_css('td', text: 'No query')
        expect(page).to_not have_css('td', text: @sub_list.name)

        visit mailing_list_path(@sub_list.id)
        expect(page).to have_css('td', text: @sub_list.name)
        expect(page).to_not have_css('td', text: @mailing_list.name)
      end

      it "displays a count of members" do
        visit mailing_list_path(@mailing_list)
        expect(page).to have_css('th', text: 'Fixed members')
        expect(page).to have_css('td', text: pluralize(@mailing_list.members.count, 'member') + " (of #{Member.count} total)")
      end

      it "allows expansion of members list" do
        pending "Capybara can't tell it's hidden"
        visit mailing_list_path(@mailing_list)
        expect(page).to_not have_content(@mailing_list.members.first.surname)

        page.first('label', text: pluralize(@mailing_list.members.count, 'member')).click
        expect(page).to have_content(@mailing_list.members.first.surname)
        expect(page).to have_content(@mailing_list.members.last.surname)
      end

      it "displays interpreted dynamic query, if it exists" do
        # Query for simple dynamic list
        visit mailing_list_path(@simple_dynamic_list)
        expect(page.find 'tr', text: 'Varying members').to have_css('td', text: "<forename or email> CONTAINS 'ian'")

        # Query for complex dynamic list
        visit mailing_list_path(@complex_dynamic_list)
        expect(page.find 'tr', text: 'Varying members').to have_css('td', text: "<membership> EQUALS 'Life Patron' OR (<membership> EQUALS 'Patron' AND <subs_paid> EQUALS 'true'")

        # Query including references to static lists
        visit mailing_list_path(@list_difference_list)
        expect(page.find 'tr', text: 'Varying members').to have_css('td', text: "<mailing_lists_name> EQUALS 'Publicity' AND <mailing_lists_name> NOT EQUAL TO 'Only some members'")
      end

      it "displays current matching members for dynamic query" do
        # We'll need a number of Members for this test, with varying information that matches - or not - the
        # defined queries. We'll be working with "<forename or email> CONTAINS 'ian'" and
        # "<membership> EQUALS 'Life Patron' OR (<membership> EQUALS 'Patron' AND <subs_paid> EQUALS 'true')"
        members = [
          {forename: 'Ian', surname: 'Rankin'},
          {forename: 'John', surname: 'Smith', email: 'js.ians.mate@example.com'},
          {forename: 'Bob', surname: 'Roberts', membership: 'Patron', subs_paid: true},
          {forename: 'Jane', surname: 'Ian', email:'jane@example.com'},
          {forename: 'Brian', surname: 'Cox', membership: 'Life Patron'},
          {forename: 'Ian', surname: 'Duncan-Smith', email: 'iands@example.com'},
          {forename: 'Ernie', surname: 'Wise', membership: 'Patron', subs_paid: false},
          {forename: 'Julianos', surname: 'the Wise'}
        ]
        Member.destroy_all
        members.each { |member| Member.create member }
        expect(Member.count).to eq members.size

        # Check we match all the Ians in forename and email. Expect case insensitivity
        visit mailing_list_path @simple_dynamic_list
        matching = ['Ian Rankin', 'John Smith', 'Brian Cox', 'Ian Duncan-Smith', 'Julianos the Wise']
        matching.each do |name|
          expect(page.find 'tr', text: 'Varying members').to have_content name
        end

        mismatching = members.map { |m| "#{m[:forename]} #{m[:surname]}" } - matching
        mismatching.each do |name|
          expect(page.find 'tr', text: 'Varying members').to_not have_content name
        end

        # Now check we match the patrons
        visit mailing_list_path @complex_dynamic_list
        matching = ['Bob Roberts', 'Brian Cox']
        matching.each do |name|
          expect(page.find 'tr', text: 'Varying members').to have_content name
        end

        mismatching = members.map { |m| "#{m[:forename]} #{m[:surname]}" } - matching
        mismatching.each do |name|
          expect(page.find 'tr', text: 'Varying members').to_not have_content name
        end

        # Test list with fixed and dynamic members
        @simple_dynamic_list.members = Member.where.has { surname.like_any ['Rankin', 'Roberts', '%Wise'] }
        @simple_dynamic_list.save

        visit mailing_list_path @simple_dynamic_list

        # ...Varying members
        matching = ['Ian Rankin', 'John Smith', 'Brian Cox', 'Ian Duncan-Smith', 'Julianos the Wise']
        matching.each do |name|
          expect(page.find 'tr', text: 'Varying members').to have_content name
        end

        mismatching = members.map { |m| "#{m[:forename]} #{m[:surname]}" } - matching
        mismatching.each do |name|
          expect(page.find 'tr', text: 'Varying members').to_not have_content name
        end

        # ...fixed members
        matching = ['Ian Rankin', 'Bob Roberts', 'Ernie Wise', 'Julianos the Wise']
        matching.each do |name|
          expect(page.find 'tr', text: 'Fixed members').to have_content name
        end

        mismatching = members.map { |m| "#{m[:forename]} #{m[:surname]}" } - matching
        mismatching.each do |name|
          expect(page.find 'tr', text: 'Fixed members').to_not have_content name
        end

        # Test list referring to other lists
        @mailing_list.members = Member.all
        @mailing_list.save
        @sub_list.members = [2, 3, 5, 7].map { |ix| Member.where.has { (forename == members[ix][:forename]) & (surname == members[ix][:surname]) }.first }
        @sub_list.save
        visit mailing_list_path @list_difference_list
        matching = members.values_at(0, 1, 4, 6).map { |m| "#{m[:forename]} #{m[:surname]}" }
        matching.each do |name|
          expect(page.find 'tr', text: 'Varying members').to have_content name
        end

        mismatching = members.values_at(2, 3, 5, 7).map { |m| "#{m[:forename]} #{m[:surname]}" }
        mismatching.each do |name|
          expect(page.find 'tr', text: 'Fixed members').to_not have_content name
        end
      end

      describe "with js", js: true do
        it "allows expansion of members list" do
          visit mailing_list_path(@mailing_list)
          fullname = @mailing_list.members.first.fullname
          expect(page).to_not have_css('a', text: fullname, visible: true)

          page.first('label', text: pluralize(@mailing_list.members.count, 'member')).click
          expect(page).to have_css('a', text: fullname, visible: true)
          fullname = @mailing_list.members.last.forename + " " + @mailing_list.members.last.surname
          expect(page).to have_css('a', text: fullname, visible: true)
        end
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

      it "allows selection of members" do
        visit new_mailing_list_path
        fill_in 'Name', with: "Choosing some members"

        page.select "#{@member1.forename} #{@member1.surname}", from: 'Members'
        page.select "#{@member2.forename} #{@member2.surname}", from: 'Members'
        click_button 'Save'
        expect(MailingList.last.members).to match_array [@member1, @member2]
      end

      it "allows definition of dynamic query", js: true do
        visit new_mailing_list_path
        fill_in 'Name', with: "Defining query"

        expect(page).to have_content 'No query defined'
        click_button 'Define query'
        sleep 0.5
        expect(page).to_not have_content 'No query defined'

        # Set up the following query:
        # (<forename> EQUALS 'ian' OR
        #  ((<address> CONTAINS 'Chippenham' AND <surname> DOES NOT EQUAL 'Smith' AND <show_fee_paid> EQUALS 'true') OR
        #    <phone> DOES NOT CONTAIN '01225'))
        page.first('select.combinator-select option', text: 'Any').select_option
        expect(page).to_not have_css 'select.attrib-select'
        page.first('button', text: '+ <?>').click
        sleep 0.5
        page.first('select.attrib-select option', text: 'Postcode').select_option
        page.first('select.pred-select option', text: 'equals').select_option
        page.first('input.value-text').set 'AA0 0AA'

        # Remove and re-add a condition
        page.first('button.remove-condition').click
        sleep 0.5

        expect(page).to_not have_css 'select.attrib-select'
        page.first('button', text: '+ <?>').click
        sleep 0.5
        page.first('select.attrib-select option', text: 'Forename').select_option
        page.first('select.pred-select option', text: 'equals').select_option
        page.first('input.value-text').set 'ian'

        page.first('button', text: '+ {').click
        sleep 0.5
        page.all('select.combinator-select')[1].find('option', text: 'Any').select_option
        page.all('button', text: '+ <?>')[1].click
        sleep 0.5
        page.all('select.attrib-select option', text: 'Mobile')[1].select_option
        page.all('select.pred-select option', text: 'equals')[1].select_option
        page.all('input.value-text')[1].set '01234 567890'

        # Remove and re-add a group
        page.first('button.remove-group').click
        sleep 0.5

        page.first('button', text: '+ {').click
        sleep 0.5
        page.all('select.combinator-select')[1].find('option', text: 'Any').select_option
        page.all('button', text: '+ <?>')[1].click
        sleep 0.5
        page.all('select.attrib-select option', text: 'Phone')[1].select_option
        page.all('select.pred-select option', text: "doesn't contain")[1].select_option
        page.all('input.value-text')[1].set '01225'

        # Add-group buttons appear just before the group's closing brace. So we want the first one.
        page.all('button', text: '+ {')[0].click
        sleep 0.5
        page.all('select.combinator-select')[2].find('option', text: 'All').select_option
        page.all('button', text: '+ <?>')[2].click
        sleep 0.5
        page.all('select.attrib-select')[2].first('option', text: /^Address$/).select_option
        page.all('select.pred-select option', text: 'contains')[2].select_option
        page.all('input.value-text')[2].set 'Chippenham'

        page.all('button', text: '+ <?>')[2].click
        sleep 0.5
        page.all('select.attrib-select option', text: 'Surname')[3].select_option
        page.all('select.pred-select option', text: 'not equal to')[3].select_option
        page.all('input.value-text')[3].set 'Smith'


        page.all('button', text: '+ <?>')[2].click
        sleep 0.5
        page.all('select.attrib-select option', text: 'Show fee paid')[4].select_option
        page.all('select.pred-select option', text: 'equals')[4].select_option
        page.all('input.value-text')[4].set 'true'

        click_button 'Save'
        expect(page.find 'tr', text: 'Varying members').to have_css('td', text:
"<forename> EQUALS 'ian' OR (<phone> DOESN'T CONTAIN '01225' OR (<address> CONTAINS 'Chippenham' AND <surname> NOT EQUAL TO 'Smith' AND <show_fee_paid> EQUALS 'true'))"
        )
        expect(MailingList.last.members).to be_empty
      end

      it "allows dynamic query and selected members", js: true do
        visit new_mailing_list_path
        fill_in 'Name', with: "Defining query plus members"

        expect(page).to have_content 'No query'
        click_button 'Define query'
        sleep 0.5
        expect(page).to_not have_content 'No query'

        # Set up a simple dynamic query
        page.first('select.combinator-select option', text: 'Any').select_option
        expect(page).to_not have_css 'select.attrib-select'
        page.first('button', text: '+ <?>').click
        sleep 0.5
        page.first('select.attrib-select option', text: 'Postcode').select_option
        page.first('select.pred-select option', text: 'equals').select_option
        page.first('input.value-text').set 'AA0 0AA'

        # Select some members
        page.select "#{@member2.forename} #{@member2.surname}", from: 'Members'
        page.select "#{@member3.forename} #{@member3.surname}", from: 'Members'
        click_button 'Save'
        expect(MailingList.last.members).to match_array [@member2, @member3]
        expect(page.find 'tr', text: 'Varying members').to have_css('td', text: "<postcode> EQUALS 'AA0 0AA'")
      end

      it "ignores a hidden dynamic query", js: true do
        visit new_mailing_list_path
        fill_in 'Name', with: "Defining then hiding query"

        expect(page).to have_content 'No query'
        click_button 'Define query'
        sleep 0.5
        expect(page).to_not have_content 'No query'

        # Set up a simple dynamic query
        page.first('select.combinator-select option', text: 'Any').select_option
        expect(page).to_not have_css 'select.attrib-select'
        page.first('button', text: '+ <?>').click
        sleep 0.5
        page.first('select.attrib-select option', text: 'Postcode').select_option
        page.first('select.pred-select option', text: 'equals').select_option
        page.first('input.value-text').set 'AA0 0AA'

        # Now hide it
        click_button 'Remove query'

        # Select some members
        page.select "#{@member2.forename} #{@member2.surname}", from: 'Members'
        page.select "#{@member3.forename} #{@member3.surname}", from: 'Members'
        click_button 'Save'
        expect(MailingList.last.members).to match_array [@member2, @member3]
        expect(page.find 'tr', text: 'Varying members').to have_css('td', text: 'No query')
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

      it "allows selection of members" do
        visit mailing_list_path(@sub_list)
        click_link 'Edit'

        page.unselect "#{@member1.forename} #{@member1.surname}", from: 'Members'
        page.select "#{@member2.forename} #{@member2.surname}", from: 'Members'
        click_button 'Save'
        expect(MailingList.find(@sub_list.id).members).to match_array [@member2, @member3]

        click_link 'Edit'
        page.unselect "#{@member2.forename} #{@member2.surname}", from: 'Members'
        page.unselect "#{@member3.forename} #{@member3.surname}", from: 'Members'
        click_button 'Save'
        expect(MailingList.find(@sub_list.id).members).to be_empty
      end

      it "allows definition of dynamic query", js: true do
        visit edit_mailing_list_path(@sub_list)
        fill_in 'Name', with: "Defining query"

        expect(page).to have_content 'No query defined'
        click_button 'Define query'
        sleep 0.5
        expect(page).to_not have_content 'No query defined'

        # Set up the following query:
        # (<forename> EQUALS 'ian' OR
        #  ((<address> CONTAINS 'Chippenham' AND <surname> DOES NOT EQUAL 'Smith' AND <show_fee_paid> EQUALS 'true') OR
        #    <phone> DOES NOT CONTAIN '01225'))
        page.first('select.combinator-select option', text: 'Any').select_option
        expect(page).to_not have_css 'select.attrib-select'
        page.first('button', text: '+ <?>').click
        sleep 0.5
        page.first('select.attrib-select option', text: 'Postcode').select_option
        page.first('select.pred-select option', text: 'equals').select_option
        page.first('input.value-text').set 'AA0 0AA'

        # Remove and re-add a condition
        page.first('button.remove-condition').click
        sleep 0.5

        expect(page).to_not have_css 'select.attrib-select'
        page.first('button', text: '+ <?>').click
        sleep 0.5
        page.first('select.attrib-select option', text: 'Forename').select_option
        page.first('select.pred-select option', text: 'equals').select_option
        page.first('input.value-text').set 'ian'

        page.first('button', text: '+ {').click
        sleep 0.5
        page.all('select.combinator-select')[1].find('option', text: 'Any').select_option
        page.all('button', text: '+ <?>')[1].click
        sleep 0.5
        page.all('select.attrib-select option', text: 'Mobile')[1].select_option
        page.all('select.pred-select option', text: 'equals')[1].select_option
        page.all('input.value-text')[1].set '01234 567890'

        # Remove and re-add a group
        page.first('button.remove-group').click
        sleep 0.5

        page.first('button', text: '+ {').click
        sleep 0.5
        page.all('select.combinator-select')[1].find('option', text: 'Any').select_option
        page.all('button', text: '+ <?>')[1].click
        sleep 0.5
        page.all('select.attrib-select option', text: 'Phone')[1].select_option
        page.all('select.pred-select option', text: "doesn't contain")[1].select_option
        page.all('input.value-text')[1].set '01225'

        # Add-group buttons appear just before the group's closing brace. So we want the first one.
        page.all('button', text: '+ {')[0].click
        sleep 0.5
        page.all('select.combinator-select')[2].find('option', text: 'All').select_option
        page.all('button', text: '+ <?>')[2].click
        sleep 0.5
        page.all('select.attrib-select')[2].first('option', text: /^Address$/).select_option
        page.all('select.pred-select option', text: 'contains')[2].select_option
        page.all('input.value-text')[2].set 'Chippenham'

        page.all('button', text: '+ <?>')[2].click
        sleep 0.5
        page.all('select.attrib-select option', text: 'Surname')[3].select_option
        page.all('select.pred-select option', text: 'not equal to')[3].select_option
        page.all('input.value-text')[3].set 'Smith'


        page.all('button', text: '+ <?>')[2].click
        sleep 0.5
        page.all('select.attrib-select option', text: 'Show fee paid')[4].select_option
        page.all('select.pred-select option', text: 'equals')[4].select_option
        page.all('input.value-text')[4].set 'true'

        click_button 'Save'
        expect(page.find 'tr', text: 'Varying members').to have_css('td', text:
"<forename> EQUALS 'ian' OR (<phone> DOESN'T CONTAIN '01225' OR (<address> CONTAINS 'Chippenham' AND <surname> NOT EQUAL TO 'Smith' AND <show_fee_paid> EQUALS 'true'))"
        )
        expect(MailingList.last.members).to be_empty
      end

      it "allows dynamic query and selected members", js: true do
        visit mailing_list_path(@simple_dynamic_list)
        expect(page.find 'tr', text: 'Varying members').to have_css('td', text: "<forename or email> CONTAINS 'ian'")

        click_link 'Edit'

        expect(page).to_not have_content 'No query defined'

        # Set up a simple dynamic query
        page.first('select.combinator-select option', text: 'Any').select_option
        expect(page).to_not have_css 'select.attrib-select'
        page.first('button', text: '+ <?>').click
        sleep 0.5
        page.first('select.attrib-select option', text: 'Postcode').select_option
        page.first('select.pred-select option', text: 'equals').select_option
        page.first('input.value-text').set 'AA0 0AA'

        # Select some members
        page.unselect "#{@member1.forename} #{@member1.surname}", from: 'Members'
        page.select "#{@member2.forename} #{@member2.surname}", from: 'Members'
        page.select "#{@member3.forename} #{@member3.surname}", from: 'Members'
        click_button 'Save'
        expect(@simple_dynamic_list.members.reload).to match_array [@member2, @member3]
        expect(page.find 'tr', text: 'Varying members').to have_css('td', text: "<postcode> EQUALS 'AA0 0AA'")
      end

      it "ignores a hidden dynamic query", js: true do
        visit mailing_list_path(@complex_dynamic_list)
        expect(page.find 'tr', text: 'Varying members').to have_css('td', text: "<membership> EQUALS 'Life Patron' OR (<membership> EQUALS 'Patron' AND <subs_paid> EQUALS 'true'")

        click_link 'Edit'

        click_button 'Remove query'

        # Select some members
        page.unselect "#{@member1.forename} #{@member1.surname}", from: 'Members'
        page.select "#{@member2.forename} #{@member2.surname}", from: 'Members'
        page.select "#{@member3.forename} #{@member3.surname}", from: 'Members'
        click_button 'Save'
        expect(@complex_dynamic_list.members.reload).to match_array [@member2, @member3]
        expect(page.find 'tr', text: 'Varying members').to have_css('td', text: 'No query')
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

        expect(MailingList.where.has { name == old_name }.first).to be_nil
        expect(current_path).to eq mailing_lists_path
      end

      it "does not destroy members" do
        visit mailing_lists_path
        page.first('a span.icon-remove').find(:xpath, '..').click
        expect(Member.find(@member1.id)).to_not be_nil
      end
    end
  end
end
