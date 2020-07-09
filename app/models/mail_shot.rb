require 'base64'

class MailShot
  MERGE_FIELDS = [:forename, :surname, :fullname, :addr1, :addr2, :addr3, :town, :county, :postcode,
                  :address, :phone, :mobile, :voice, :membership, :email, :subs_paid, :show_fee_paid,
                  :concert_fee_paid, :mailing_list_names, :notes, :join_year]

  Attachment = Struct.new(:filename, :data, :mime_type)

  def initialize(current_user, params)
    @mailing_list_id = params[:mailing_list_id]
    @subject = params[:subject]
    @body = params[:body]
    @reply_to = ENV['SOCIETY_EMAIL']
    @reply_to = current_user.email if params[:reply_to_sender]
    @attachments = params[:attachments].andand.map do |attach|
      Attachment.new(attach.original_filename, attach.read, attach.content_type)
    end
  end

  def send_emails
    list = MailingList.find(@mailing_list_id)

    members = list.members
    members += Member.ransack(list.query).result if list.query.present?
    members.uniq.each do |recpt|
      next unless recpt.email =~ EMAIL_PATTERN

      body = merge_body recpt
      MailShotsMailer.mail_shot(subject: @subject,
                                to: recpt.email,
                                body: body,
                                reply_to_addr: @reply_to,
                                attaches: @attachments || []).deliver_now
    end
  rescue => e
    Rails.logger.info e
    Rails.logger.info e.backtrace
  end

  private

  def merge_body(member)
    MERGE_FIELDS.inject(@body) { |body, field| body.gsub "<#{field}>", member.send(field).to_s }
  end
end
