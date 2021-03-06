require 'base64'

class InboundParseController < ApplicationController
  def parse
    inbound_mail = Mail.new(params['email'])
    body = (inbound_mail.text_part || inbound_mail.body).decoded

    # Look for the magic string that tells us where to bounce it
    match = /RMID:\s*(\S*)/m.match(body)
    b64_addr = match[1]
    addr = Base64.decode64(b64_addr)

    # And do so.
    MailShotsMailer.bounce_on(to: addr,
                              subject: inbound_mail.subject,
                              body: body,
                              from: inbound_mail.from,
                              attaches: inbound_mail.attachments).deliver_now

  rescue => e
    Rails.logger.info('Inbound parse failed.')
    Rails.logger.info("#{e.class}: #{e.message}")
    Rails.logger.info(e.backtrace[0..2])
    AdminMailer.bounce_on_failed(params).deliver
  ensure
    head :no_content
  end
end
