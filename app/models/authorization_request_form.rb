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

  def self.backend
    yaml_records + db_records
  end

  def self.yaml_records
    AuthorizationRequestFormConfigurations.instance.all.map do |uid, hash|
      build(uid, hash.deep_symbolize_keys)
    end
  end

  def self.db_records
    return [] unless FormTemplate.table_exists?

    FormTemplate.includes(:habilitation_type).filter_map do |template|
      build_form_from_template(template)
    end
  rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid
    []
  end

  # rubocop:disable Metrics/AbcSize
  def self.build_form_from_template(template)
    klass = authorization_request_class_for(template.habilitation_type)
    return unless klass

    ht = template.habilitation_type
    new(
      uid: template.slug,
      default: template.default,
      name: cascaded(template.name, ht.name),
      description: cascaded(template.description, ht.description),
      introduction: cascaded(template.introduction, ht.form_introduction),
      public: template.public,
      startable_by_applicant: template.startable_by_applicant,
      use_case: template.use_case,
      single_page_view: template.single_page_view,
      service_provider: template.service_provider,
      authorization_request_class: klass,
      steps: cascaded_steps(template, ht),
      static_blocks: template.static_blocks.map(&:deep_symbolize_keys),
      scopes_config: template.scopes_config.deep_symbolize_keys,
      initialize_with: template.initialize_with.deep_symbolize_keys,
    )
  end
  # rubocop:enable Metrics/AbcSize

  def self.cascaded(template_value, fallback)
    template_value.presence || fallback
  end

  def self.cascaded_steps(template, habilitation_type)
    template.steps.presence&.map(&:deep_symbolize_keys) ||
      habilitation_type.ordered_steps.map { |step_name| { name: step_name } }
  end

  def self.authorization_request_class_for(record)
    AuthorizationRequest.const_get(record.uid.classify)
  rescue NameError
    nil
  end

  private_class_method :yaml_records, :db_records, :build_form_from_template, :cascaded, :cascaded_steps, :authorization_request_class_for

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
  def france_connect_certified?
    service_provider&.france_connect_certified? && service_provider.apipfc_enabled?
  end

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

  def name_with_service_provider
    if @name && service_provider
      "#{@name} - #{service_provider.name}"
    elsif @name
      @name
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
    initialize_with = (@initialize_with || {}).dup

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
