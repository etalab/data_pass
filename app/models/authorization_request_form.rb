class AuthorizationRequestForm < StaticApplicationRecord
  attr_accessor :uid,
    :name,
    :description,
    :public,
    :logo,
    :authorization_request_class,
    :scopes,
    :templates,
    :steps,
    :unique

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
        :logo,
        :public,
        :unique
      ).merge(
        uid: uid.to_s,
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

  def multiple_steps?
    steps.any?
  end
end
