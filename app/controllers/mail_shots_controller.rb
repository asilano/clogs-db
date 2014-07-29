class MailShotsController < ApplicationController
  # Can't do anything unless signed in
  before_filter :authenticate_user!

  def new
    @list = MailingList.find_by_id(params[:mailing_list_id].to_i)
  end

  def create
    @list = MailingList.find_by_id(params[:mailing_list_id].to_i)

    if @list
      # Queue sending mail here
      delay.send_emails(params.slice :mailing_list_id, :body)
      flash[:notice] = "Emails created, and queued for delivery"
    else
      flash[:error] = "You must specify a mailing list"
    end

    redirect_to action: :new
  end
end
