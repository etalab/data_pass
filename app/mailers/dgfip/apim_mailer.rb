class DGFIP::APIMMailer < ApplicationMailer
  DGFIP_APIM_EMAIL = 'dtnum.donnees.demande-acces@dgfip.finances.gouv.fr'.freeze

  def approve
    @authorization = params[:authorization]
    @authorization_request = @authorization.request
    @reopening = params[:reopening]
    @stage_label = stage_label

    mail(
      to: DGFIP_APIM_EMAIL,
      subject: subject_for_approve
    )
  end

  private

  def subject_for_approve
    if @reopening
      I18n.t(
        'dgfip_apim_mailer.approve.reopening_subject',
        authorization_request_id: @authorization_request.id
      )
    else
      I18n.t(
        'dgfip_apim_mailer.approve.subject',
        authorization_request_id: @authorization_request.id
      )
    end
  end

  def stage_label
    return '' unless @authorization_request.definition.stage.exists?

    case @authorization_request.definition.stage.type
    when 'sandbox'
      'BAS'
    when 'production'
      'PROD'
    else
      ''
    end
  end
end
