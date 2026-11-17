class PagesController < ApplicationController
  include Authentication
  include SubdomainsHelper

  allow_unauthenticated_access

  before_action :ensure_html_format

  def home
    return redirect_to dashboard_path if user_signed_in?

    redirect_to connexion_path if registered_subdomain?
  end

  def connexion
    redirect_to dashboard_path if user_signed_in?
  end

  def faq; end

  def cgu_api_impot_particulier_bas
    render 'static_pages/cgu_api_impot_particulier_bas'
  end

  def cgu_api_impot_particulier_prod
    render 'static_pages/cgu_api_impot_particulier_prod'
  end

  def accessibilite
    render 'static_pages/accessibilite'
  end

  def plan_action_accessibilite
    render 'static_pages/plan_action_accessibilite'
  end

  def mentions_legales
    render 'static_pages/mentions_legales'
  end

  def politique_confidentialite
    render 'static_pages/politique_confidentialite'
  end

  private

  def layout_name
    action_name == 'home' ? 'wide_container' : super
  end

  def ensure_html_format
    head :not_acceptable unless request.format.html?
  end
end
