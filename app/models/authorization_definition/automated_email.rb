class AuthorizationDefinition::AutomatedEmail
  EVENTS = %w[submit approve refuse request_changes revoke].freeze

  ALL = {
    'submit_to_applicant' => { event: 'submit', recipient: 'applicant' },
    'submit_to_instructors' => { event: 'submit', recipient: 'instructors' },
    'approve_to_applicant' => { event: 'approve', recipient: 'applicant' },
    'approve_to_responsable_traitement' => { event: 'approve', recipient: 'responsable_traitement' },
    'approve_to_delegue_protection_donnees' => { event: 'approve', recipient: 'delegue_protection_donnees' },
    'approve_to_france_connect' => { event: 'approve', recipient: 'france_connect' },
    'approve_to_dgfip_apim' => { event: 'approve', recipient: 'dgfip_apim' },
    'approve_to_hubee_administrateur_metier_cert_dc' => { event: 'approve', recipient: 'hubee_administrateur_metier', hubee_kind: 'cert_dc' },
    'approve_to_hubee_administrateur_metier_dila' => { event: 'approve', recipient: 'hubee_administrateur_metier', hubee_kind: 'dila' },
    'refuse_to_applicant' => { event: 'refuse', recipient: 'applicant' },
    'request_changes_to_applicant' => { event: 'request_changes', recipient: 'applicant' },
    'revoke_to_applicant' => { event: 'revoke', recipient: 'applicant' },
  }.freeze

  DEFAULT_IDS = %w[
    submit_to_applicant
    submit_to_instructors
    approve_to_applicant
    approve_to_responsable_traitement
    approve_to_delegue_protection_donnees
    refuse_to_applicant
    request_changes_to_applicant
    revoke_to_applicant
  ].freeze

  attr_reader :id, :event, :recipient, :hubee_kind

  def self.find(id)
    new(id:, **ALL.fetch(id))
  end

  def initialize(id:, event:, recipient:, hubee_kind: nil)
    @id = id
    @event = event
    @recipient = recipient
    @hubee_kind = hubee_kind
  end

  def to_applicant?
    recipient == 'applicant'
  end

  def gdpr_contact?
    %w[responsable_traitement delegue_protection_donnees].include?(recipient)
  end
end
