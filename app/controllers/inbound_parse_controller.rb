require 'base64'

class InboundParseController < ApplicationController

  def parse
    inbound_mail = Mail.new(params["email"])
    body = inbound_mail.text_part.decoded

    # Look for the magic string that tells us where to bounce it
    match = /RMID: (.*)$/.match(body)
    b64_addr = match[1]
    addr = Base64::decode64(b64_addr)

    # And do so.
    mail = ActionMailer::Base.mail from: ENV['SOCIETY_EMAIL'], to: addr, subject: inbound_mail.subject
    out_body = <<EOM
Hi there!

Someone replied to a message you sent through the CLOGS Membership database. That reply is below, and any attachments have been forwarded on.

Please DO NOT reply to this email! This email has come from the database too, and it'll just get very confusing. Instead, create a new email to the actual sender if you need to contact them.

Message from: #{inbound_mail.from}

Message:

#{body}

EOM

    mail.content_type = 'multipart/mixed'
    mail.part content_type: 'text/plain', body: out_body
    inbound_mail.attachments.each do |att|
      mail.attachments[att.filename] = att.decoded
    end
    mail.deliver

    render text: "Received: #{params}"
  end

end
