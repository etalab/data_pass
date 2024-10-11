class HubEEMailer < ApplicationMailer
  def administrateur_metier(kind)
    @authorization_request = params[:authorization_request]

    mail(
      to: @authorization_request.administrateur_metier_email,
      subject: subject_for(kind),
      template_name: "administrateur_metier_#{kind}"
    )
  end

  def subject_for(kind)
    case kind
    when :cert_dc
      'Vous avez été désigné administrateur local HubEE pour une démarche CertDC'
    when :dila
      'Vous avez été désigné administrateur local HubEE pour des démarches service-public.fr'
    else
      raise "Unknown hubee email kind: #{kind}"
    end
  end
end
