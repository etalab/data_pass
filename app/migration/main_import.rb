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
      # "target_api = 'franceconnect' order by id asc",
      "target_api like '%_sandbox' order by id asc",
      "target_api not in (#{target_apis_not_to_import}) and target_api not like '%_sandbox' and target_api != 'franceconnect' order by id asc",
      # "target_api in ('api_impot_particulier_sandbox') order by id asc",
      # "target_api in ('api_impot_particulier_production') order by id asc",
    ].each do |where_sql|
      authorization_requests = import(:authorization_requests, { load_from_sql: false, dump_sql: true, authorization_requests_sql_where: where_sql})

      if types_to_import.any?
        valid_authorization_request_ids = AuthorizationRequest.where(id: authorization_requests.pluck(:id), type: types_to_import).pluck(:id)
      else
        valid_authorization_request_ids = AuthorizationRequest.where(id: authorization_requests.pluck(:id)).where.not(type: already_imported_authorization_request_types).pluck(:id)
      end

      import(:authorization_request_events, { dump_sql: true, valid_authorization_request_ids: })
    end

    %i[warned skipped].each do |kind|
      export(kind)
      print_stats(kind)
    end
  end

  private

  def import_extra_authorization_requests_sql_data
    Dir[Rails.root.join('app/migration/dumps/authorization_requests_sql_to_load/*.sql')].sort.each do |file|
      log("# Importing file #{File.basename(file)}")

      `psql -d #{ActiveRecord::Base.connection.current_database} -f #{file}`
    end
  end

  def types_to_import
    %w[
    ]
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
        %w[42429 44675 51940 61032 44701].include?(enrollment_row['id'])
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

  def target_apis_to_import
    %w[
      api_rial
      api_cpr_pro
      api_e_contacts
      api_e_pro
      api_ensu_documents
      api_hermes
      api_imprimfip
      api_mire
      api_ocfi
      api_opale
      api_robf
      api_satelit
      api_sfip
    ].map do |name|
      ["'#{name}_sandbox'", "'#{name}_production'"]
    end.concat(
      [
        "'api_declaration_auto_entrepreneur'",
        "'api_declaration_cesu'",
        "'franceconnect'",
      ]
    ).flatten.join(', ')

    %w[
      api_impot_particulier
    ].map do |name|
      ["'#{name}_sandbox'", "'#{name}_production'", "'#{name}_unique'"]
    end.concat(["'franceconnect'"]).flatten.join(', ')
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
