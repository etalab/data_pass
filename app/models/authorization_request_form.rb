class AuthorizationRequestForm < StaticApplicationRecord
  attr_accessor :uid,
    :name,
    :service_provider,
    :default,
    :use_case,
    :authorization_request_class,
    :single_page_view,
    :steps,
    :static_blocks

  attr_writer :description,
    :startable_by_applicant,
    :data,
    :introduction,
    :scopes_config,
    :public

  def self.all
    AuthorizationRequestFormConfigurations.instance.all.map do |uid, hash|
      build(uid, hash.deep_symbolize_keys)
    end
  end

  def self.build(uid, hash)
    new(
      hash.slice(
        :name,
        :description,
        :public,
        :use_case,
        :introduction,
        :single_page_view,
        :startable_by_applicant,
        :scopes_config,
      ).merge(
        uid: uid.to_s,
        service_provider: hash[:service_provider_id].present? ? ServiceProvider.find(hash[:service_provider_id]) : nil,
        default: hash[:default] || false,
        data: clean_data(hash[:data]),
        authorization_request_class: AuthorizationRequest.const_get(hash[:authorization_request]),
        steps: hash[:steps] || [],
        static_blocks: hash[:static_blocks] || [],
      )
    )
  end
  delegate :provider, to: :authorization_definition

  def id
    uid
  end

  def name_with_definition
    if @name
      "#{@name} - #{authorization_definition.name}"
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

  def introduction
    return nil if @introduction.blank?

    format(@introduction, service_provider_name: service_provider.try(:name), form_name: name)
  end

  def authorization_definition
    authorization_request_class.definition
  end

  def startable_by_applicant
    return false if next_stage_form?

    value_or_default(@startable_by_applicant, authorization_definition.startable_by_applicant)
  end

  def public
    value_or_default(@public, true)
  end

  def prefilled?
    @data.present?
  end

  def data
    data = @data || {}

    if authorization_definition.scopes.any?
      included_scopes = authorization_definition.scopes.select(&:included?)

      data[:scopes] ||= []
      data[:scopes] += included_scopes.map(&:value)
      data[:scopes].sort!
      data[:scopes].uniq!
    end

    data
  end

  def scopes_config
    @scopes_config || {}
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

  def single_page?
    !multiple_steps?
  end

  def active_authorization_requests_for(organization)
    organization
      .active_authorization_requests
      .where(type: authorization_request_class.to_s)
  end

  def self.clean_data(data)
    data ||= {}
    data.to_h do |key, value|
      [key, value.strip]
    rescue StandardError
      [key, value]
    end
  end

  private

  def next_stage_form?
    return false unless authorization_definition.stage.exists?

    (authorization_definition.stage.previous_stages || []).any? do |previous|
      previous[:form_id] == id
    end
  end
end
