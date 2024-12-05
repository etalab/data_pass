class StaticPagesController < ApplicationController
  include Authentication

  allow_unauthenticated_access only: :cgu_api_impot_particulier_bas

  def cgu_api_impot_particulier_bas
    render 'static_pages/cgu_api_impot_particulier_bas'
  end
end
