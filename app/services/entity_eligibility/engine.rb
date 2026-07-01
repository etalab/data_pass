class EntityEligibility::Engine
  attr_reader :organization, :authorization_request_form, :authorization_request

  def self.from_request(authorization_request)
    new(
      organization: authorization_request.organization,
      authorization_request_form: authorization_request.form,
      authorization_request:,
    )
  end

  def initialize(organization:, authorization_request_form:, authorization_request: nil)
    @organization = organization
    @authorization_request_form = authorization_request_form
    @authorization_request = authorization_request
  end

  def verdict
    rule_class = resolve_rule_class

    return EntityEligibility::Verdict.unknown unless rule_class

    rule_class.new(self).verdict
  end

  private

  def resolve_rule_class
    candidate_rule_names.filter_map(&:safe_constantize).first
  end

  def candidate_rule_names
    [use_case_rule_name, demarche_rule_name].compact
  end

  def use_case_rule_name
    return if authorization_request_form.use_case.blank?

    "#{demarche_rule_name}::#{authorization_request_form.use_case.camelize}"
  end

  def demarche_rule_name
    "EntityEligibility::Rules::#{authorization_request_form.authorization_request_class.name.demodulize}"
  end
end
