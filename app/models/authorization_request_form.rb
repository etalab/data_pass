class AuthorizationRequestForm
  include ActiveModel::Model

  attr_accessor :uid,
    :name,
    :description,
    :public,
    :logo,
    :authorization_request_class

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
        :public
      ).merge(
        uid: uid.to_s,
        authorization_request_class: AuthorizationRequest.const_get(hash[:authorization_request])
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
