require 'spec_helper'

describe MailingListsController do
  # This should return the minimal set of attributes required to create a valid
  # MailingList. As you add validations to MailingList, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { {:name => 'All Members'} }


  describe "while logged out" do
    describe "GET index" do
      it "redirects to login" do
        list = MailingList.create! valid_attributes
        get :index, {}
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "GET show" do
      it "redirects to login" do
        list = MailingList.create! valid_attributes
        get :show, {:id => list.to_param}
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "GET new" do
      it "redirects to login" do
        get :new, {}
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "GET edit" do
      it "redirects to login" do
        list = MailingList.create! valid_attributes
        get :edit, {:id => list.to_param}
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "POST create" do
      describe "with valid params" do
        it "does not create a new MailingList" do
          expect {
            post :create, {:mailing_list => valid_attributes}
          }.to_not change(MailingList, :count)
        end

        it "redirects to login" do
          post :create, {:mailing_list => valid_attributes}
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      describe "with invalid params" do
        it "redirects to login" do
          # Trigger the behavior that occurs when invalid params are submitted
          allow_any_instance_of(MailingList).to receive(:save).and_return(false)
          post :create, {:mailing_list => { "forename" => "invalid value" }}
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end

    describe "PUT update" do
      describe "with valid params" do
        it "does not update the requested list" do
          list = MailingList.create! valid_attributes
          expect_any_instance_of(MailingList).to_not receive(:update_attributes).with({ "forename" => "MyString" })
          put :update, {:id => list.to_param, :mailing_list => { "forename" => "MyString" }}
        end

        it "redirects to login" do
          list = MailingList.create! valid_attributes
          put :update, {:id => list.to_param, :mailing_list => valid_attributes}
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      describe "with invalid params" do
        it "redirects to login" do
          list = MailingList.create! valid_attributes
          # Trigger the behavior that occurs when invalid params are submitted
          allow_any_instance_of(MailingList).to receive(:save).and_return(false)
          put :update, {:id => list.to_param, :mailing_list => { "forename" => "invalid value" }}
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end

    describe "DELETE destroy" do
      it "does not destroy the requested list" do
        list = MailingList.create! valid_attributes
        expect {
          delete :destroy, {:id => list.to_param}
        }.to_not change(MailingList, :count)
      end

      it "redirects to login" do
        list = MailingList.create! valid_attributes
        delete :destroy, {:id => list.to_param}
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "while logged in" do
    let(:user) { FactoryGirl.create(:user) }

    before(:each) do
      sign_in user
    end

    describe "GET index" do
      it "assigns all lists as @lists" do
        list = MailingList.create! valid_attributes
        get :index, {}
        expect(assigns(:lists)).to eq([list])
      end
    end

    describe "GET show" do
      it "assigns the requested list as @list" do
        list = MailingList.create! valid_attributes
        get :show, {:id => list.to_param}
        expect(assigns(:list)).to eq(list)
      end
    end

    describe "GET new" do
      it "assigns a new list as @list" do
        get :new, {}
        expect(assigns(:list)).to be_a_new(MailingList)
      end
    end

    describe "GET edit" do
      it "assigns the requested list as @list" do
        list = MailingList.create! valid_attributes
        get :edit, {:id => list.to_param}
        expect(assigns(:list)).to eq(list)
      end
    end

    describe "POST create" do
      describe "with valid params" do
        it "creates a new MailingList" do
          expect {
            post :create, {:mailing_list => valid_attributes}
          }.to change(MailingList, :count).by(1)
        end

        it "assigns a newly created list as @list" do
          post :create, {:mailing_list => valid_attributes}
          expect(assigns(:list)).to be_a(MailingList)
          expect(assigns(:list)).to be_persisted
        end

        it "redirects to the created list" do
          post :create, {:mailing_list => valid_attributes}
          expect(response).to redirect_to(MailingList.last)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved list as @list" do
          # Trigger the behavior that occurs when invalid params are submitted
          allow_any_instance_of(MailingList).to receive(:save).and_return(false)
          post :create, {:mailing_list => { "name" => "invalid value" }}
          expect(assigns(:list)).to be_a_new(MailingList)
        end

        it "re-renders the 'new' template" do
          # Trigger the behavior that occurs when invalid params are submitted
          allow_any_instance_of(MailingList).to receive(:save).and_return(false)
          post :create, {:mailing_list => { "name" => "invalid value" }}
          expect(response).to render_template("new")
        end
      end
    end

    describe "PUT update" do
      describe "with valid params" do
        it "updates the requested list" do
          list = MailingList.create! valid_attributes
          # Assuming there are no other lists in the database, this
          # specifies that the MailingList created on the previous line
          # receives the :update_attributes message with whatever params are
          # submitted in the request.
          expect_any_instance_of(MailingList).to receive(:update_attributes).with({ "forename" => "MyString" })
          put :update, {:id => list.to_param, :mailing_list => { "forename" => "MyString" }}
        end

        it "assigns the requested list as @list" do
          list = MailingList.create! valid_attributes
          put :update, {:id => list.to_param, :mailing_list => valid_attributes}
          expect(assigns(:list)).to eq(list)
        end

        it "redirects to the list" do
          list = MailingList.create! valid_attributes
          put :update, {:id => list.to_param, :mailing_list => valid_attributes}
          expect(response).to redirect_to(list)
        end
      end

      describe "with invalid params" do
        it "assigns the list as @list" do
          list = MailingList.create! valid_attributes
          # Trigger the behavior that occurs when invalid params are submitted
          allow_any_instance_of(MailingList).to receive(:save).and_return(false)
          put :update, {:id => list.to_param, :mailing_list => { "name" => "invalid value" }}
          expect(assigns(:list)).to eq(list)
        end

        it "re-renders the 'edit' template" do
          list = MailingList.create! valid_attributes
          # Trigger the behavior that occurs when invalid params are submitted
          allow_any_instance_of(MailingList).to receive(:save).and_return(false)
          put :update, {:id => list.to_param, :mailing_list => { "name" => "invalid value" }}
          expect(response).to render_template("edit")
        end
      end
    end

    describe "DELETE destroy" do
      it "destroys the requested list" do
        list = MailingList.create! valid_attributes
        expect {
          delete :destroy, {:id => list.to_param}
        }.to change(MailingList, :count).by(-1)
      end

      it "redirects to the lists list" do
        list = MailingList.create! valid_attributes
        delete :destroy, {:id => list.to_param}
        expect(response).to redirect_to(mailing_lists_url)
      end
    end
  end
end
