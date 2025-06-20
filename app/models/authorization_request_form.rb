class AuthorizationRequestForm < StaticApplicationRecord
  attr_accessor :uid,
    :service_provider,
    :default,
    :use_case,
    :stage,
    :authorization_request_class,
    :single_page_view,
    :steps,
    :static_blocks

  attr_writer :name,
    :description,
    :startable_by_applicant,
    :initialize_with,
    :introduction,
    :scopes_config,
    :public

  def self.all
    AuthorizationRequestFormConfigurations.instance.all.map do |uid, hash|
      build(uid, hash.deep_symbolize_keys)
    end
  end

  # rubocop:disable Metrics/AbcSize
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
        initialize_with: clean_data(hash[:initialize_with]),
        authorization_request_class: AuthorizationRequest.const_get(hash[:authorization_request]),
        steps: hash[:steps] || [],
        static_blocks: hash[:static_blocks] || [],
        stage: build_stage(hash[:stage] || {}, hash[:authorization_request]),
      )
    )
  end
  # rubocop:enable Metrics/AbcSize

  delegate :provider, to: :authorization_definition

  def id
    uid
  end

  def name
    @name || authorization_definition.name
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
    @initialize_with.present?
  end

  def initialize_with
    initialize_with = @initialize_with || {}

    if authorization_definition.scopes.any?
      included_scopes = authorization_definition.scopes.select(&:included?)

      initialize_with[:scopes] ||= []
      initialize_with[:scopes] += included_scopes.map(&:value)
      initialize_with[:scopes].sort!
      initialize_with[:scopes].uniq!
    end

    initialize_with
  end

  def scopes_config
    @scopes_config || {}
  end

  alias data initialize_with

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

  def self.clean_data(initialize_with)
    initialize_with ||= {}
    initialize_with.to_h do |key, value|
      [key, value.strip]
    rescue StandardError
      [key, value]
    end
  end

  def self.build_stage(stage_data, authorization_request_class)
    definition = AuthorizationRequest.const_get(authorization_request_class).definition

    return nil unless definition.stage.exists?

    AuthorizationRequestForm::Stage.new(
      stage_data.merge(
        definition: AuthorizationRequest.const_get(authorization_request_class).definition
      )
    )
  end

  private

  def next_stage_form?
    return false unless authorization_definition.stage.exists?
    return false unless authorization_definition.stage.previous_stage?

    authorization_definition.stage.previous_stage[:form_id] == id
  end
end
