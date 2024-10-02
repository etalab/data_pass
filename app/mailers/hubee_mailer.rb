class HubEEMailer < ApplicationMailer
  def administrateur_metier_cert_dc
    @authorization_request = params[:authorization_request]

    mail(
      to: @authorization_request.administrateur_metier_email,
      subject: subject_for(__method__)
    )
  end

  alias administrateur_metier_dila administrateur_metier_cert_dc

  def subject_for(name)
    case name
    when :administrateur_metier_cert_dc
      'Vous avez été désigné administrateur local HubEE pour une démarche CertDC'
    when :administrateur_metier_dila
      'Vous avez été désigné administrateur local HubEE pour des démarches service-public.fr'
    else
      raise "Unknown email name: #{name}"
    end
  end
end
