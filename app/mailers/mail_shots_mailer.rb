class MailShotsMailer < ActionMailer::Base
  default from: ENV['SOCIETY_EMAIL']

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.mail_shots_mailer.mail_shot.subject
  #
  def mail_shot(subject: nil,
                to: nil,
                body: nil,
                reply_to_addr: ENV['SOCIETY_EMAIL'],
                attaches: [])
    @body = body
    @reply_to_addr = reply_to_addr
    attaches.each do |attach|
      attachments[attach.filename] = { mime_type: attach.mime_type, content: attach.data }
    end

    mail(subject: subject, to: to)
  end
end
