class AuthorizationDefinition < StaticApplicationRecord
  attr_accessor :id,
    :name,
    :provider,
    :description,
    :link,
    :access_link,
    :cgu_link,
    :kind,
    :scopes,
    :blocks,
    :stage,
    :unique

  attr_writer :startable_by_applicant,
    :public

  def self.all
    AuthorizationDefinitionConfigurations.instance.all.map do |uid, hash|
      build(uid, hash.deep_symbolize_keys)
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
        :public,
        :kind,
        :startable_by_applicant,
        :unique,
      ).merge(
        id: uid.to_s,
        provider: DataProvider.find(hash[:provider]),
        stage: Stage.new(hash[:stage]),
        scopes: (hash[:scopes] || []).map { |scope_data| AuthorizationRequestScope.new(scope_data) },
        blocks: hash[:blocks] || [],
      )
    )
  end

  def reopenable?
    !next_stage?
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

  def startable_by_applicant
    value_or_default(@startable_by_applicant, true)
  end

  delegate :next_stage_form, :next_stage_definition, :next_stage?, to: :stage

  def authorization_request_class
    @authorization_request_class ||= AuthorizationRequest.const_get(id.classify)
  end
end
