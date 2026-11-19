module INSEEFictive
  FIXTURES_PATH = Rails.root.join('spec/fixtures/insee')
  FALLBACK_SIRETS = {
    'public' => '21920023500014',
    'prive' => '32816124500027',
  }.freeze

  module_function

  def enabled?
    Rails.env.development? && ENV['INSEE_FICTIVE'].present?
  end

  def etablissement(siret)
    known_fixture = FIXTURES_PATH.join("#{siret}.json")
    return JSON.parse(known_fixture.read) if known_fixture.exist?

    JSON.parse(fallback_fixture.read).deep_merge(
      'etablissement' => { 'siret' => siret, 'siren' => siret.first(9), 'nic' => siret.last(5) }
    )
  end

  def fallback_fixture
    FIXTURES_PATH.join("#{FALLBACK_SIRETS.fetch(ENV.fetch('INSEE_FICTIVE', nil), FALLBACK_SIRETS['prive'])}.json")
  end

  module Client
    def etablissement(siret:)
      INSEEFictive.etablissement(siret)
    end
  end

  module CallsAlwaysAllowed
    def calls_allowed?
      true
    end
  end

  module NeverSkipped
    private

    def skip_development?
      false
    end
  end
end

Rails.application.config.to_prepare do
  next unless INSEEFictive.enabled?

  INSEESireneAPIClient.prepend(INSEEFictive::Client)
  AbstractINSEEAPIClient.singleton_class.prepend(INSEEFictive::CallsAlwaysAllowed)
  UpdateOrganizationINSEEPayloadJob.prepend(INSEEFictive::NeverSkipped)
end
