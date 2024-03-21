class AuthorizationDefinition < StaticApplicationRecord
  attr_accessor :id,
    :name,
    :provider,
    :description,
    :link,
    :cgu_link,
    :scopes,
    :blocks

  attr_writer :unique,
    :startable_by_applicant,
    :public,
    :webhook

  def self.all
    Rails.application.config_for(:authorization_definitions).map do |uid, hash|
      build(uid, hash)
    end
  end

  def editors
    available_forms.select { |form|
      form.editor.present?
    }.map(&:editor).uniq
  end

  def self.indexable
    where(
      public: true,
      startable_by_applicant: true,
    )
  end

  def self.build(uid, hash)
    new(
      hash.slice(
        :name,
        :description,
        :link,
        :cgu_link,
        :public,
        :webhook,
        :startable_by_applicant,
        :unique
      ).merge(
        id: uid.to_s,
        provider: DataProvider.find(hash[:provider]),
        scopes: (hash[:scopes] || []).map { |scope_data| AuthorizationRequestScope.new(scope_data) },
        blocks: hash[:blocks] || [],
      )
    )
  end

  def unique?
    value_or_default(@unique, false)
  end

  def reopenable?
    true
  end

  def instructors
    User.instructor_for(id)
  end

  def available_forms
    AuthorizationRequestForm.where(authorization_request_class:).sort do |form|
      form.default ? 1 : 0
    end
  end

  def public
    value_or_default(@public, true)
  end

  def webhook? = value_or_default(@webhook, false)

  def startable_by_applicant
    value_or_default(@startable_by_applicant, true)
  end

  def authorization_request_class
    @authorization_request_class ||= AuthorizationRequest.const_get(id.classify)
  end
end
