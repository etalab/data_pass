class AuthorizationRequestCreationRules
  def self.for_form(form, organization:, applicant: nil)
    new(definition: form.authorization_definition, startable: form.startable_by_applicant, organization:, applicant:)
  end

  def self.for_definition(definition, organization:, applicant: nil)
    new(definition:, startable: true, organization:, applicant:)
  end

  def self.for_request_class(authorization_request_class, organization:, applicant: nil)
    new(
      definition: authorization_request_class.definition,
      startable: authorization_request_class.startable_by_applicant,
      organization:,
      applicant:
    )
  end

  def initialize(definition:, startable:, organization:, applicant: nil)
    @definition = definition
    @startable = startable
    @organization = organization
    @applicant = applicant
  end

  def creation_violation
    access_violation || (:unicity_violated if unicity_violated?)
  end

  def access_violation
    return :applicant_banned if applicant_known_and_banned?
    return :form_not_startable unless startable?

    :organization_closed unless organization_active?
  end

  def startable?
    @startable
  end

  def organization_active?
    organization.blank? || !organization.closed?
  end

  def unicity_violated?
    definition.unique &&
      organization.present? &&
      organization.active_authorization_requests.exists?(type: definition.authorization_request_class_as_string)
  end

  private

  attr_reader :definition, :organization, :applicant

  def applicant_known_and_banned?
    applicant.present? && applicant.banned?
  end
end
