class ApplicationController < ActionController::Base
  protect_from_forgery

  layout :layout_from_resource

protected
  def layout_from_resource
    devise_controller? ? 'devise' : 'application'
  end
end
