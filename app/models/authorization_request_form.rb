class AuthorizationRequestForm < StaticApplicationRecord
  attr_accessor :uid,
    :name,
    :description,
    :provider,
    :authorization_request_class,
    :scopes,
    :templates,
    :steps,
    :unique

  attr_writer :startable_by_applicant,
    :public

  def self.all
    Rails.application.config_for(:authorization_request_forms).map do |uid, hash|
      build(uid, hash)
    end
  end

  def self.build(uid, hash)
    new(
      hash.slice(
        :name,
        :description,
        :public,
        :startable_by_applicant,
        :unique
      ).merge(
        uid: uid.to_s,
        provider: DataProvider.find(hash[:provider]),
        authorization_request_class: AuthorizationRequest.const_get(hash[:authorization_request]),
        templates: (hash[:templates] || []).map { |template_key, template_attributes| AuthorizationRequestTemplate.new(template_key, template_attributes) },
        scopes: (hash[:scopes] || []).map { |scope_attributes| AuthorizationRequestScope.new(scope_attributes) },
        steps: hash[:steps] || []
      )
    )
  end

  def id
    uid
  end

  def link
    link || provider.link
  end

  def startable_by_applicant
    value_or_default(@startable_by_applicant, true)
  end

  def public
    value_or_default(@public, true)
  end

  def self.indexable
    where(
      public: true,
      startable_by_applicant: true,
    )
  end

  delegate :logo, to: :provider

  def multiple_steps?
    steps.any?
  end

  private

  def value_or_default(value, default)
    value.nil? ? default : value
  end
end
