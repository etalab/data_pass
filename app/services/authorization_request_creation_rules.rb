class AuthorizationRequestCreationRules
  def initialize(form:, organization:, applicant: nil)
    @form = form
    @organization = organization
    @applicant = applicant
  end

  def creation_violation
    return :applicant_banned if applicant_known_and_banned?
    return :form_not_startable unless startable?
    return :organization_closed unless organization_active?

    :unicity_violated if unicity_violated?
  end

  def startable?
    form.startable_by_applicant
  end

  def organization_active?
    organization.blank? || !organization.closed?
  end

  def unicity_violated?
    form.authorization_definition.unique &&
      organization.present? &&
      form.active_authorization_requests_for(organization).exists?
  end

  private

  attr_reader :form, :organization, :applicant

  def applicant_known_and_banned?
    applicant.present? && applicant.banned?
  end
end
