class MailShot
  MERGE_FIELDS = [:forename, :surname, :fullname, :addr1, :addr2, :addr3, :town, :county, :postcode,
                  :address, :phone, :mobile, :voice, :membership, :email, :subs_paid, :show_fee_paid,
                  :concert_fee_paid, :mailing_list_names]

  def initialize(params)
    @mailing_list_id = params[:mailing_list_id]
    @subject = params[:subject]
    @body = params[:body]
  end

  def send_emails
    list = MailingList.find(@mailing_list_id)

    list.members.each do |recpt|
      next unless recpt.email =~ EMAIL_PATTERN

      body = merge_body recpt
      mail = ActionMailer::Base.mail from: ENV['SOCIETY_EMAIL'], to: recpt.email, subject: @subject, body: body
      mail.deliver
    end
  rescue
  end

private
  def merge_body(member)
    MERGE_FIELDS.inject(@body) { |body, field| body.gsub "<#{field}>", member.send(field).to_s }
  end
end