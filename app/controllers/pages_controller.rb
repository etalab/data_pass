class PagesController < ApplicationController
  include Authentication

  allow_unauthenticated_access

  def home
    redirect_to dashboard_path if user_signed_in?
  end
end
