class DGFIP::APIMMailer < ApplicationMailer
  def approve
    @authorization = params[:authorization]
    @authorization_request = @authorization.request
    @reopening = params[:reopening]
    @stage_label = stage_label

    mail(
      to: dgfip_emails,
      subject: subject_for_approve
    )
  end

  private

  def subject_for_approve
    if @reopening
      I18n.t(
        'dgfip_apim_mailer.approve.reopening_subject',
        authorization_request_id: @authorization_request.formatted_id
      )
    else
      I18n.t(
        'dgfip_apim_mailer.approve.subject',
        authorization_request_id: @authorization_request.formatted_id
      )
    end
  end

  def dgfip_emails
    apim_emails + api_specific_emails
  end

  def apim_emails
    Rails.application.credentials.dgfip_apim_emails || []
  end

  def api_specific_emails
    (Rails.application.credentials.dgfip_api_specific_emails || {})[@authorization_request.definition.id.to_sym] || []
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
