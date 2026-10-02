class Seeds
  STEPS = [
    Seeds::DemCommuneReferenceRequests,
    Seeds::BoursiersHabilitationType,
    Seeds::OauthApplication,
    Seeds::VerifiedEmails,
    Seeds::StatsVolumeRequests,
    Seeds::HistoricalRequests,
    Seeds::ClamartHubEECertDCRequest,
    Seeds::MessageTemplates,
    Seeds::Webhooks,
  ].freeze

  def perform
    create_data_providers
    create_organizations_and_accounts

    STEPS.each { |step| step.new(context).perform }
  end

  def flushdb
    raise 'Not in production!' if production?

    ActiveRecord::Base.connection.execute(truncate_all_tables_statement)
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

  private

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

  def create_organizations_and_accounts
    organizations.perform
    accounts.perform
  end

  def truncate_all_tables_statement
    connection = ActiveRecord::Base.connection
    tables = (connection.tables - %w[schema_migrations ar_internal_metadata]).map { |table| connection.quote_table_name(table) }

    "TRUNCATE TABLE #{tables.join(', ')} RESTART IDENTITY CASCADE;"
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
end
