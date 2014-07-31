class MailShot
  def initialize(params)
    @mailing_list_id = params[:mailing_list_id]
    @subject = params[:subject]
    @body = params[:body]
  end

  def send_emails
    list = MailingList.find(@mailing_list_id)

    list.members.each do |recpt|
      mail = ActionMailer::Base.mail from: ENV['SOCIETY_EMAIL'], to: recpt.email, subject: @subject, body: @body
      mail.deliver
    end
  rescue
  end
end