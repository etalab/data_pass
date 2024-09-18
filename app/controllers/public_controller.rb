class PublicController < ApplicationController
  include AccessAuthorization

  def current_user
    @current_user ||= User.new
  end

  def user_signed_in?
    false
  end

  def displayed_on_a_public_page?
    true
  end
end
