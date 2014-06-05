class AdminMailer < ActionMailer::Base
  default from: ENV['ADMIN_EMAIL']

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.admin.approval_needed.subject
  #
  def approval_needed(user)
    @user = user

    mail to: ENV['ADMIN_EMAIL'], subject: "User wants approval for Clogs Members"
  end
end
