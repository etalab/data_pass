class AutomatedEmailPreview
  SAMPLE_AUTHORIZATION_REQUEST_ID = 'N°XXXX'.freeze

  RECIPIENT_PREVIEW_CLASSES = {
    'applicant' => 'Applicant',
    'instructors' => 'Instructors',
    'responsable_traitement' => 'GDPRContact',
    'delegue_protection_donnees' => 'GDPRContact',
    'france_connect' => 'FranceConnect',
    'dgfip_apim' => 'DGFIPAPIM',
    'hubee_administrateur_metier' => 'HubEEAdministrateurMetier',
  }.freeze

  def self.for(definition, automated_email)
    "AutomatedEmailPreview::#{RECIPIENT_PREVIEW_CLASSES.fetch(automated_email.recipient)}"
      .constantize
      .new(definition, automated_email)
  end

  attr_reader :definition, :automated_email

  delegate :event, :recipient, to: :automated_email

  def initialize(definition, automated_email)
    @definition = definition
    @automated_email = automated_email
  end

  def recipient_emails
    nil
  end

  def body
    ApplicationController.render(template: body_template, assigns:, formats: [:text])
  rescue StandardError
    nil
  end

  private

  def assigns
    { authorization_request: sample_authorization_request }
  end

  def sample_authorization_request
    @sample_authorization_request ||= SampleAuthorizationRequest.new(definition)
  end

  def template_exists?(path)
    ApplicationController.new.lookup_context.exists?(path, [], false, [], formats: [:text])
  end
end
