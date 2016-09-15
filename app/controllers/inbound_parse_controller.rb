require 'base64'

class InboundParseController < ApplicationController

  def parse
    inbound_mail = Mail.new(params["email"])
    body = inbound_mail.text_part.decoded

    # Look for the magic string that tells us where to bounce it
    match = /RMID: (.*)$/.match(body)
    b64_addr = match[1]
    addr = Base64::decode64(b64_addr)

    # And do so. Just frobble the to address, and add replace the body.
    inbound_mail.to = addr
    out_body = <<EOM
Hi there!

Someone replied to a message you sent through the CLOGS Membership database. That reply is below, and any attachments have been forwarded on.

Please DO NOT reply to this email! This email has come from the database too, and it'll just get very confusing. Instead, create a new email to the actual sender if you need to contact them.

Message from: #{inbound_mail.from}

Message:

#{body}

EOM

    text_pt = inbound_mail.parts.detect { |pt| pt.content_type =~ /^text\/plain/ }
    text_pt.body = out_body
    inbound_mail.deliver

    render text: "Handled email"
  end

end
