require 'spec_helper'

describe MailShotsController do
  let(:mailing_list) { FactoryGirl.create(:mailing_list) }
  let(:valid_attributes) { {mailing_list_id: mailing_list.id.to_s, body: "Hello"} }

  describe "while logged out" do
    describe "GET new" do
      it "redirects to login" do
        get :new, {mailing_list_id: 1}
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "POST create" do
      describe "with valid params" do
        it "redirects to login" do
          post :create, valid_attributes
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      describe "with invalid params" do
        it "redirects to login" do
          # Trigger the behavior that occurs when invalid params are submitted
          post :create, :mailing_list_id => "invalid value"
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end
  end

  describe "while logged in" do
    let(:user) { FactoryGirl.create(:user) }

    before(:each) do
      sign_in user
      @mock_delay = double('mock_delay').as_null_object
      MailShotsController.any_instance.stub(:delay).and_return @mock_delay
    end

    describe "GET new" do
      it "prefills the mailing list if given" do
        get :new, {:mailing_list_id => mailing_list.id}
        expect(assigns(:list)).to eq mailing_list
      end

      it "leaves the mailing list as nil if not given" do
        get :new, {:mailing_list_id => ''}
        expect(assigns(:list)).to be_nil
      end
    end

    describe "POST create" do
      describe "with valid params" do
        it "redirects to the new mail-shot page" do
          post :create, valid_attributes
          expect(response).to redirect_to(new_mail_shot_path)
        end

        it "has a successful flash" do
          post :create, valid_attributes
          expect(flash[:notice]).to_not be_nil
        end

        it "delays creating the emails" do
          expect(@mock_delay).to receive(:send_emails).with HashWithIndifferentAccess.new(valid_attributes)
          post :create, valid_attributes
        end
      end

      describe "with invalid params" do
        it "redirects to the new mail-shot page" do
          post :create, {:mailing_list_id => "invalid value"}
          expect(response).to redirect_to(new_mail_shot_path)
        end

        it "has an error flash" do
          post :create, {:mailing_list_id => "invalid value"}
          expect(flash[:error]).to_not be_nil
        end
      end
    end
  end
end
