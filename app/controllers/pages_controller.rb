class PagesController < ApplicationController
  include Authentication

  allow_unauthenticated_access

  def home
    redirect_to dashboard_path if user_signed_in?
  end

  def cgu_api_impot_particulier_bas
    render 'static_pages/cgu_api_impot_particulier_bas'
  end

  def cgu_api_impot_particulier_prod
    render 'static_pages/cgu_api_impot_particulier_prod'
  end

  def accessibilite
    render 'static_pages/accessibilite'
  end
end
