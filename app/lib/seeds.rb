class Seeds
  STEPS = [
    :create_dem_commune_scenarios,
    Seeds::BoursiersHabilitationType,
    Seeds::OauthApplication,
    Seeds::VerifiedEmails,
    :create_stats_data,
    Seeds::HistoricalRequests,
    Seeds::ClamartHubEECertDCRequest,
    Seeds::MessageTemplates,
    Seeds::Webhooks,
  ].freeze

  def perform
    create_data_providers
    create_organizations_and_accounts

    STEPS.each do |step|
      step.is_a?(Symbol) ? send(step) : step.new(context).perform
    end
  end

  def flushdb
    raise 'Not in production!' if production?

    connection = ActiveRecord::Base.connection

    connection.tables.each do |table|
      next if %w[schema_migrations ar_internal_metadata].include?(table)

      connection.execute("TRUNCATE TABLE #{connection.quote_table_name(table)} RESTART IDENTITY CASCADE;")
    end

    flush_unread_messages_counters
  end

  def create_data_providers
    seeds_for(:data_providers).each do |slug, attributes|
      provider = DataProvider.find_or_initialize_by(
        slug: slug.to_s,
      )

      provider.assign_attributes(
        name: attributes[:name],
        link: attributes[:link]
      )

      provider.save!(validate: false)

      provider.logo.attach(
        io: Rails.root.join('app', 'assets', 'images', 'data_providers', attributes[:logo]).open,
        filename: attributes[:logo],
      )

      provider.save!
    end
  end

  protected

  def organizations
    @organizations ||= Seeds::ReferenceOrganizations.new
  end

  def accounts
    @accounts ||= Seeds::TestAccounts.new(organizations)
  end

  def requests
    @requests ||= Seeds::AuthorizationRequestInState.new(accounts)
  end

  def context
    @context ||= Seeds::Context.new(organizations:, accounts:, requests:)
  end

  private

  def create_organizations_and_accounts
    organizations.perform
    accounts.perform
  end

  def seeds_for(name)
    YAML.load(Rails.root.join('db', 'seeds', "#{name}.yml").read, aliases: true).deep_symbolize_keys[:shared]
  end

  def flush_unread_messages_counters
    redis = Kredis.configured_for(:shared)
    counter_keys = redis.scan_each(match: Kredis.namespaced_key('authorization_request:*:redis_unread_messages_*')).to_a

    redis.del(*counter_keys) if counter_keys.any?
  end

  def production?
    Rails.env.production? && ENV['CAN_FLUSH_DB'].blank?
  end

  def create_dem_commune_scenarios
    Seeds::DemCommuneScenarios.new(self).perform
  end

  def create_stats_data
    Seeds::Stats.new(self).perform
  end
end
