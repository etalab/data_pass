class AutomatedEmailPreview::DGFIPAPIM < AutomatedEmailPreview
  SampleAuthorization = Struct.new(:formatted_id)

  def subject
    I18n.t(
      'dgfip_apim_mailer.approve.subject',
      authorization_request_id: SAMPLE_AUTHORIZATION_REQUEST_ID,
    )
  end

  def recipient_emails
    apim_emails + api_specific_emails
  end

  private

  def body_template
    'dgfip/apim_mailer/approve'
  end

  def assigns
    super.merge(
      authorization: SampleAuthorization.new('H-XXXX'),
      reopening: false,
      stage_label:,
    )
  end

  def apim_emails
    Rails.application.credentials.dgfip_apim_emails || []
  end

  def api_specific_emails
    (Rails.application.credentials.dgfip_api_specific_emails || {})[definition.id.to_sym] || []
  end

  def stage_label
    case definition.stage.type
    when 'sandbox' then 'BAS'
    when 'production' then 'PROD'
    else ''
    end
  end
end
