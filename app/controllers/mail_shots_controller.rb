class MailShotsController < ApplicationController
  # Can't do anything unless signed in
  before_filter :authenticate_user!

  def new
    @list = MailingList.find_by_id(params[:mailing_list_id].to_i)
  end

  def create
    @list = MailingList.find_by_id(params[:mailing_list_id].to_i)

    if @list
      # Queue sending mail here.
      MailShot.new(params.slice :mailing_list_id, :subject, :body).delay.send_emails
      flash[:notice] = "Emails created, and queued for delivery."

      # Report synchronously those members which we know will fail, due to having no email address
      no_email_members = @list.members.select { |m| m.email !~ EMAIL_PATTERN }
      unless no_email_members.empty?
        flash[:notice] << "<br/><br/>The following members will not be emailed, as they do not have a configured email address:"
        flash[:notice] << '<ul>'.html_safe
        no_email_members.each { |m| flash[:notice] << "<li>#{m.fullname}</li>".html_safe }
        flash[:notice] << '</ul>'.html_safe
      end
    else
      flash[:error] = "You must specify a mailing list"
    end

    redirect_to action: :new, mailing_list_id: 1
  end
end
