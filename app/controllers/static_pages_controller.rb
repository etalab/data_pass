class StaticPagesController < ApplicationController
  include Authentication

  allow_unauthenticated_access only: %i[cgu_api_impot_particulier_bas cgu_api_impot_particulier_prod]

  def cgu_api_impot_particulier_bas
    render 'static_pages/cgu_api_impot_particulier_bas'
  end

  def cgu_api_impot_particulier_prod
    render 'static_pages/cgu_api_impot_particulier_prod'
  end
end
