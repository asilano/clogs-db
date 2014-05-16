require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe MembersController do

  # This should return the minimal set of attributes required to create a valid
  # Member. As you add validations to Member, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { }


  describe "while logged out" do
    describe "GET index" do
      it "redirects to login" do
        member = Member.create! valid_attributes
        get :index, {}
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "GET show" do
      it "redirects to login" do
        member = Member.create! valid_attributes
        get :show, {:id => member.to_param}
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
        member = Member.create! valid_attributes
        get :edit, {:id => member.to_param}
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "POST create" do
      describe "with valid params" do
        it "does not create a new Member" do
          expect {
            post :create, {:member => valid_attributes}
          }.to_not change(Member, :count)
        end

        it "redirects to login" do
          post :create, {:member => valid_attributes}
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      describe "with invalid params" do
        it "redirects to login" do
          # Trigger the behavior that occurs when invalid params are submitted
          allow_any_instance_of(Member).to receive(:save).and_return(false)
          post :create, {:member => { "forename" => "invalid value" }}
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end

    describe "PUT update" do
      describe "with valid params" do
        it "does not update the requested member" do
          member = Member.create! valid_attributes
          expect_any_instance_of(Member).to_not receive(:update_attributes).with({ "forename" => "MyString" })
          put :update, {:id => member.to_param, :member => { "forename" => "MyString" }}
        end

        it "redirects to login" do
          member = Member.create! valid_attributes
          put :update, {:id => member.to_param, :member => valid_attributes}
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      describe "with invalid params" do
        it "redirects to login" do
          member = Member.create! valid_attributes
          # Trigger the behavior that occurs when invalid params are submitted
          allow_any_instance_of(Member).to receive(:save).and_return(false)
          put :update, {:id => member.to_param, :member => { "forename" => "invalid value" }}
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end

    describe "DELETE destroy" do
      it "does not destroy the requested member" do
        member = Member.create! valid_attributes
        expect {
          delete :destroy, {:id => member.to_param}
        }.to_not change(Member, :count)
      end

      it "redirects to login" do
        member = Member.create! valid_attributes
        delete :destroy, {:id => member.to_param}
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
      it "assigns all members as @members" do
        member = Member.create! valid_attributes
        get :index, {}
        expect(assigns(:members)).to eq([member])
      end
    end

    describe "GET show" do
      it "assigns the requested member as @member" do
        member = Member.create! valid_attributes
        get :show, {:id => member.to_param}
        expect(assigns(:member)).to eq(member)
      end
    end

    describe "GET new" do
      it "assigns a new member as @member" do
        get :new, {}
        expect(assigns(:member)).to be_a_new(Member)
      end
    end

    describe "GET edit" do
      it "assigns the requested member as @member" do
        member = Member.create! valid_attributes
        get :edit, {:id => member.to_param}
        expect(assigns(:member)).to eq(member)
      end
    end

    describe "POST create" do
      describe "with valid params" do
        it "creates a new Member" do
          expect {
            post :create, {:member => valid_attributes}
          }.to change(Member, :count).by(1)
        end

        it "assigns a newly created member as @member" do
          post :create, {:member => valid_attributes}
          expect(assigns(:member)).to be_a(Member)
          expect(assigns(:member)).to be_persisted
        end

        it "redirects to the created member" do
          post :create, {:member => valid_attributes}
          expect(response).to redirect_to(Member.last)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved member as @member" do
          # Trigger the behavior that occurs when invalid params are submitted
          allow_any_instance_of(Member).to receive(:save).and_return(false)
          post :create, {:member => { "forename" => "invalid value" }}
          expect(assigns(:member)).to be_a_new(Member)
        end

        it "re-renders the 'new' template" do
          # Trigger the behavior that occurs when invalid params are submitted
          allow_any_instance_of(Member).to receive(:save).and_return(false)
          post :create, {:member => { "forename" => "invalid value" }}
          expect(response).to render_template("new")
        end
      end
    end

    describe "PUT update" do
      describe "with valid params" do
        it "updates the requested member" do
          member = Member.create! valid_attributes
          # Assuming there are no other members in the database, this
          # specifies that the Member created on the previous line
          # receives the :update_attributes message with whatever params are
          # submitted in the request.
          expect_any_instance_of(Member).to receive(:update_attributes).with({ "forename" => "MyString" })
          put :update, {:id => member.to_param, :member => { "forename" => "MyString" }}
        end

        it "assigns the requested member as @member" do
          member = Member.create! valid_attributes
          put :update, {:id => member.to_param, :member => valid_attributes}
          expect(assigns(:member)).to eq(member)
        end

        it "redirects to the member" do
          member = Member.create! valid_attributes
          put :update, {:id => member.to_param, :member => valid_attributes}
          expect(response).to redirect_to(member)
        end
      end

      describe "with invalid params" do
        it "assigns the member as @member" do
          member = Member.create! valid_attributes
          # Trigger the behavior that occurs when invalid params are submitted
          allow_any_instance_of(Member).to receive(:save).and_return(false)
          put :update, {:id => member.to_param, :member => { "forename" => "invalid value" }}
          expect(assigns(:member)).to eq(member)
        end

        it "re-renders the 'edit' template" do
          member = Member.create! valid_attributes
          # Trigger the behavior that occurs when invalid params are submitted
          allow_any_instance_of(Member).to receive(:save).and_return(false)
          put :update, {:id => member.to_param, :member => { "forename" => "invalid value" }}
          expect(response).to render_template("edit")
        end
      end
    end

    describe "DELETE destroy" do
      it "destroys the requested member" do
        member = Member.create! valid_attributes
        expect {
          delete :destroy, {:id => member.to_param}
        }.to change(Member, :count).by(-1)
      end

      it "redirects to the members list" do
        member = Member.create! valid_attributes
        delete :destroy, {:id => member.to_param}
        expect(response).to redirect_to(members_url)
      end
    end
  end
end
