require 'spec_helper'

describe InboundParseController do
  describe 'POST well-formed mail' do
    it 'should bounce on and OK' do
      email = <<HEADERS
Subject: Test email
To: CLOGS Musical Theatre <membership@example.com>

HEADERS

      body = <<EOF
This is testing bounce-on.

----

If you wish to reply to the sender of this email, please reply leaving the following line intact:
EOF
      body << "RMID: #{Base64.encode64('bob@example.com').chomp}"
      email << body

      expect { post :parse, params: { email: email } }.
        to change { ActionMailer::Base.deliveries.size }.by(1)
      expect(response).to be_success
      email = ActionMailer::Base.deliveries.last
      expect(email.body).to include('This is testing bounce-on.')
      expect(email.to).to eq ['bob@example.com']
    end

    it 'should bounce a failure to the admin' do
      email = <<HEADERS
Subject: Test email
To: CLOGS Musical Theatre <membership@example.com>

HEADERS

      body = <<EOF
This is testing failed bounce-on.

----

If you wish to reply to the sender of this email, please reply leaving the following line intact:
EOF
      email << body

      expect { post :parse, params: { email: email } }.
        to change { ActionMailer::Base.deliveries.size }.by(1)
      expect(response).to be_success
      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to eq 'Bounce-on failed'
      expect(email.body).to include('threw an exception')
      expect(email.body).to include('This is testing failed bounce-on.')
      expect(email.to).to eq [ENV['ADMIN_EMAIL']]
    end
  end
end
