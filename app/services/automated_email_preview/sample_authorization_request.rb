class AutomatedEmailPreview::SampleAuthorizationRequest
  SampleApplicant = Struct.new(:full_name, :email)
  SampleOrganization = Struct.new(:name)

  class SampleReason
    def initialize(reason, present: true)
      @reason = reason
      @present = present
    end

    attr_reader :reason

    def present?
      @present
    end
  end

  attr_reader :definition

  def initialize(definition)
    @definition = definition
  end

  def id = 0
  def to_param = '0'
  def formatted_id = AutomatedEmailPreview::SAMPLE_AUTHORIZATION_REQUEST_ID
  def name = '[Intitulé de la demande]'
  def reopening? = false
  def latest_authorization = nil
  def last_submitted_at = Time.current
  def applicant = SampleApplicant.new('[Nom du demandeur]', '[email du demandeur]')
  def organization = SampleOrganization.new('[Nom de l’organisation]')
  def denial = SampleReason.new('[Motif de refus]')
  def revocation = SampleReason.new('[Motif de révocation]')
  def modification_request = SampleReason.new('[Modifications demandées]', present: false)
  def responsable_traitement_given_name = '[Prénom du responsable de traitement]'
  def delegue_protection_donnees_given_name = '[Prénom du délégué à la protection des données]'
  def administrateur_metier_given_name = '[Prénom de l’administrateur métier]'
  def administrateur_metier_family_name = '[Nom de l’administrateur métier]'
  def administrateur_metier_email = '[email de l’administrateur métier]'
  def contact_technique_email = '[email du contact technique]'
  def scopes = ['[Périmètre de données]']
end
