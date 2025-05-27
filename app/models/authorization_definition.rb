class AuthorizationDefinition < StaticApplicationRecord
  include ActiveModel::Serialization

  attr_accessor :id,
    :name,
    :provider,
    :description,
    :link,
    :access_link,
    :cgu_link,
    :support_email,
    :kind,
    :scopes,
    :blocks,
    :features,
    :stage

  attr_writer :startable_by_applicant,
    :public,
    :unique

  def self.all
    AuthorizationDefinitionConfigurations.instance.all.map do |uid, hash|
      build(uid, hash)
    end
  end

  def self.where(params)
    all.select do |definition|
      params.all? do |key, value|
        definition_value = definition.send(key)
        value = [value] unless value.is_a?(Array)
        definition_value = definition_value.to_s if key == :authorization_request_class

        value.include?(definition_value)
      end
    end
  end

  def editors
    available_forms.select { |form|
      form.service_provider.present? && form.service_provider.editor?
    }.map(&:service_provider).uniq(&:id).sort_by(&:name)
  end

  def self.build(uid, hash)
    new(
      hash.slice(
        :name,
        :description,
        :link,
        :cgu_link,
        :access_link,
        :support_email,
        :public,
        :kind,
        :startable_by_applicant,
        :unique,
      ).merge(
        id: uid.to_s,
        provider: DataProvider.find(hash[:provider]),
        stage: Stage.new(hash[:stage]),
        scopes: (hash[:scopes] || []).map { |scope_data| AuthorizationDefinition::Scope.new(scope_data) },
        blocks: hash[:blocks] || [],
        features: Hash(hash[:features]).transform_keys(&:to_sym),
      )
    )
  end

  def name_with_stage
    if stage.exists?
      "#{name} (#{stage.name})"
    else
      name
    end
  end

  def reopenable?
    true
  end

  def feature?(name)
    features.fetch(name.to_sym, true)
  end

  def need_homologation?
    %w[api_entreprise api_particulier].include?(id)
  end

  def instructors
    User.instructor_for(id)
  end

  def reporters
    User.reporter_for(id)
  end

  def instructors_or_reporters
    (instructors + reporters).uniq
  end

  def public_available_forms
    available_forms.select do |form|
      form.public &&
        form.startable_by_applicant
    end
  end

  def available_forms
    AuthorizationRequestForm.where(authorization_request_class:).sort do |form|
      form.default ? 1 : 0
    end
  end

  def public
    value_or_default(@public, true)
  end

  def unique
    value_or_default(@unique, false)
  end

  def startable_by_applicant
    value_or_default(@startable_by_applicant, true)
  end

  def multi_stage?
    stage.exists?
  end

  delegate :next_stage_form, :next_stage_definition, :next_stage?, to: :stage

  def authorization_request_class
    @authorization_request_class ||= AuthorizationRequest.const_get(id.classify)
  end
end
