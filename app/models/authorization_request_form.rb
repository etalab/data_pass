class AuthorizationRequestForm
  include ActiveModel::Model

  attr_accessor :uid,
    :name,
    :description,
    :public,
    :logo,
    :authorization_request_class,
    :scopes,
    :templates,
    :unique

  def self.all
    Rails.application.config_for(:authorization_request_forms).map do |uid, hash|
      build(uid, hash)
    end
  end

  def self.where(options)
    all.select do |authorization_form|
      options.all? do |key, value|
        authorization_form.send(key) == value
      end
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
        scopes: (hash[:scopes] || []).map { |scope_attributes| AuthorizationRequestScope.new(scope_attributes) }
      )
    )
  end

  def self.find(uid)
    all.find { |authorization_form| authorization_form.uid == uid } || raise(ActiveRecord::RecordNotFound)
  end

  def id
    uid
  end

  def logo_path
    "authorization_request_forms_logos/#{logo}"
  end

  def view_path
    uid.underscore
  end
end
