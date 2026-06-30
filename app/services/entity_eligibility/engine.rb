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
    "EntityEligibility::Rules::#{authorization_request_form.uid.tr('-', '_').camelize}".constantize
  rescue NameError
    nil
  end
end
