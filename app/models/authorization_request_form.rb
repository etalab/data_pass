class AuthorizationRequestForm < StaticApplicationRecord
  attr_accessor :uid,
    :name,
    :editor,
    :default,
    :authorization_request_class,
    :templates,
    :steps

  attr_writer :description,
    :startable_by_applicant,
    :data,
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
        :data,
        :startable_by_applicant
      ).merge(
        uid: uid.to_s,
        editor: hash[:editor_id].present? ? Editor.find(hash[:editor_id]) : nil,
        default: hash[:default].nil? ? false : hash[:default],
        authorization_request_class: AuthorizationRequest.const_get(hash[:authorization_request]),
        templates: (hash[:templates] || []).map { |template_key, template_attributes| AuthorizationRequestTemplate.new(template_key, template_attributes) },
        steps: hash[:steps] || []
      )
    )
  end

  delegate :provider, :unique?, to: :authorization_definition

  def id
    uid
  end

  def name_with_authorization
    if @name
      "#{authorization_definition.name} - #{@name}"
    else
      authorization_definition.name
    end
  end

  def description
    @description || authorization_definition.description
  end

  def link
    link || provider.link
  end

  def authorization_definition
    authorization_request_class.definition
  end

  def startable_by_applicant
    value_or_default(
      value_or_default(
        @startable_by_applicant,
        authorization_definition.startable_by_applicant
      ),
      true,
    )
  end

  def public
    value_or_default(@public, true)
  end

  def data
    @data || {}
  end

  def self.indexable
    where(
      public: true,
      startable_by_applicant: true,
    )
  end

  def multiple_steps?
    steps.any?
  end
end
