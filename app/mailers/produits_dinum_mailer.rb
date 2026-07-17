class ProduitsDinumMailer < ApplicationMailer
  def transmit_convention
    @authorization_request = params[:authorization_request]
    @convention_url = convention_url

    mail(
      to: @authorization_request.contact_technique_email,
      subject: t('.subject', authorization_request_id: @authorization_request.formatted_id),
    )
  end

  private

  def convention_url
    "#{root_url}conventions/convention_mise_a_disposition_produits_dinum.pdf"
  end
end
