class User < ApplicationRecord

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable :trackable, and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  after_create :send_admin_mail

  def send_admin_mail
    AdminMailer.approval_needed(self).deliver_now
  end

  def active_for_authentication?
    super && approved?
  end

  def inactive_message
    if !approved?
      :not_approved
    else
      super
    end
  end

  def unauthenticated_message
    if !approved?
      :not_approved
    else
      super
    end
  end
end
