require 'csv'

class MainImport
  include ImportUtils

  attr_reader :skipped, :warned, :authorization_request_ids

  def initialize(authorization_request_ids: [])
    @skipped = []
    @warned = []
    @global_enrollment_ids_to_import_for_events = []
    @authorization_request_ids = authorization_request_ids
  end

  def perform
    import(:organizations, { load_from_sql: true })
    import(:users, { load_from_sql: true })

    # import_extra_authorization_requests_sql_data

    [
      "target_api = 'franceconnect' order by id asc",
      "target_api like '%_sandbox' order by id asc",
      "target_api not in (#{target_apis_not_to_import}) and target_api not like '%_sandbox' and target_api != 'franceconnect' order by id asc",
      # "target_api in ('api_impot_particulier_sandbox') order by id asc",
      # "target_api in ('api_impot_particulier_production') order by id asc",
    ].each do |where_sql|
      authorization_requests = import(:authorization_requests, { load_from_sql: false, dump_sql: false, authorization_requests_sql_where: where_sql})

      if types_to_import.any?
        valid_authorization_request_ids = AuthorizationRequest.where(id: authorization_requests.pluck(:id), type: types_to_import).pluck(:id)
      else
        valid_authorization_request_ids = AuthorizationRequest.where(id: authorization_requests.pluck(:id)).where.not(type: already_imported_authorization_request_types).pluck(:id)
      end

      import(:authorization_request_events, { dump_sql: false, valid_authorization_request_ids: }) unless authorization_requests.blank?
    end

    clean_extra_authorizations_from_old_fake_reopening!

    %i[warned skipped].each do |kind|
      export(kind)
      print_stats(kind)
    end
  end

  private

  def types_to_import
    %w[]
  end

  def import_extra_authorization_requests_sql_data
    Dir[Rails.root.join('app/migration/dumps/authorization_requests_sql_to_load/*.sql')].sort.each do |file|
      log("# Importing file #{File.basename(file)}")

      `psql -d #{ActiveRecord::Base.connection.current_database} -f #{file}`
    end
  end

  def import(klass_name, options = {})
    if authorization_request_ids.any?
      options[:authorization_request_ids] = authorization_request_ids

      options[:authorization_requests_sql_where] = "id IN (#{authorization_request_ids.join(',')})"
      options[:users_sql_where] = "id IN (select user_id from events where authorization_request_id IN (#{authorization_request_ids.join(',')})) or id IN (select user_id from enrollments where id IN(#{authorization_request_ids.join(',')}))"
      options[:authorization_request_events_sql_where] = "authorization_request_id IN (#{authorization_request_ids.join(',')}) order by id asc"
    end

    Import.const_get(klass_name.to_s.classify << 's').new(global_options.merge(options)).perform
  end

  def export(kind)
    return unless ENV['LOCAL'] == 'true'

    data = public_send(kind)
    CSV.open(export_path(kind), 'w') do |csv|
      csv << %w[id target_api kind status url]

      data.each do |datum|
        csv << [datum.id, datum.target_api, datum.kind, datum.status, "https://datapass.api.gouv.fr/#{datum.target_api.gsub('_', '-')}/#{datum.id}"]
      end
    end
  end

  def print_stats(kind)
    data = public_send(kind)
    log("# #{kind}: #{data.count}")
    log("#{kind.to_s.humanize} stats:")

    log('  - by target_api:')
    data.group_by(&:target_api).each do |target_api, skipped|
      log("  #{target_api}: #{skipped.count}")
    end

    log('  - by error type:')
    data.group_by(&:kind).each do |k, skipped|
      log("  #{k}: #{skipped.count}")
    end
  end

  def export_path(kind)
    Rails.root.join("app/migration/dumps/#{kind}.csv")
  end

  def global_options
    {
      authorization_requests_filter: ->(enrollment_row) do
        # 1 sandbox 2 productions validés API IP FC
        # %w[1560 1561 1858 12996].include?(enrollment_row['id'])

        # API IP avec 1 sandbox -> 4 productions
        # %w[42429 44675 51940 61032 44701].include?(enrollment_row['id'])

        # Demandes FC invalides à creuser car pas d'habilitation (mais approve exists)
        # %[1596 59995 63295 4441 4442 6522 7367].exclude?(enrollment_row['id'])
        # FC 2 sandbox, dernière sandbox 2 production, dont 1 crée avant la sandbox
        # %w[51496 60027 59601 64532].include?(enrollment_row['id'])
        # FC 5 sandbox, 3 productions. 1 prod sur la 1e sandbox, 2 sur la dernière
        # %w[58238 58413 59563 56274 55743 52499 53440].include?(enrollment_row['id'])

        true
      end,
      # authorization_requests_sql_where: 'target_api in (\'franceconnect\', \'api_impot_particulier_fc_sandbox\', \'api_impot_particulier_fc_production\') order by case when target_api = \'franceconnect\' then 1 when target_api like \'%_sandbox\' then 2 else 3 end',
      authorization_requests_sql_where: "target_api not in (#{target_apis_not_to_import}) order by case when target_api = 'franceconnect' then 1 when target_api like '%_sandbox' then 2 else 3 end",
      # authorization_requests_sql_where: "target_api in (#{target_apis_to_import}) order by case when target_api = 'franceconnect' then 1 when target_api like '%_sandbox' then 2 else 3 end",
      skipped: @skipped,
      warned: @warned,
      global_enrollment_ids_to_import_for_events: @global_enrollment_ids_to_import_for_events,
    }
  end

  def target_apis_not_to_import
    %w[
      api_entreprise
      api_particulier
      hubee_portail
      hubee_portail_dila
    ].map { |t| "'#{t}'" }.join(',')
  end

  def clean_extra_authorizations_from_old_fake_reopening!
    authorizations = Authorization.where(
      authorization_request_class: [
        'AuthorizationRequest::APIFicoba',
        'AuthorizationRequest::APIR2P',
        'AuthorizationRequest::APIFicobaSandbox',
        'AuthorizationRequest::APIR2PSandbox',
      ],
      id: (100_000..)
    )

    AuthorizationRequestEvent.includes(:entity).where(
      entity_type: 'Authorization',
      entity_id: authorizations.pluck(:id),
    ).find_each do |event|
      first_authorization = event.entity.request.authorizations.order(created_at: :asc).first

      event.entity_id = first_authorization.id
      first_authorization.state = first_authorization.request.state == 'revoked' ? 'revoked' : 'active'

      first_authorization.save!
      event.save!
    end

    authorizations.destroy_all
  end

  def already_imported_authorization_request_types
    %w[
      AuthorizationRequest::APIEntreprise
      AuthorizationRequest::APIParticulier
      AuthorizationRequest::HubEECertDC
      AuthorizationRequest::HubEEDila
    ]
  end
end
