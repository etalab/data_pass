class FranceConnectMailer < ApplicationMailer
  def new_scopes
    @authorization_request = params[:authorization_request]
    @france_connect_authorization_request = @authorization_request.france_connect_authorization.request

    mail(
      to: 'support.partenaires@franceconnect.gouv.fr',
      subject: new_scopes_subject(@authorization_request),
      from: 'datapass@api.gouv.fr',
      cc: 'equipe-datapass@api.gouv.fr',
    )
  end

  private

  def new_scopes_subject(authorization_request)
    "[DataPass] nouveaux scopes pour \"#{authorization_request.organization.raison_sociale} - #{authorization_request.id}\""
  end
end
