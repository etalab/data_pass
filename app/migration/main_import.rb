require 'csv'

class MainImport
  include ImportUtils

  attr_reader :skipped, :warned, :authorization_request_ids

  def initialize(authorization_request_ids: [])
    @skipped = []
    @warned = []
    @authorization_request_ids = authorization_request_ids
  end

  def perform
    import(:organizations, { load_from_sql: true })
    import(:users, { load_from_sql: true })
    authorization_requests = import(:authorization_requests, { load_from_sql: false })

    if types_to_import.any?
      valid_authorization_request_ids = AuthorizationRequest.where(id: authorization_requests.pluck(:id), type: types_to_import).pluck(:id)
    else
      valid_authorization_request_ids = authorization_requests.pluck(:id)
    end

    import(:authorization_request_events, { dump_sql: ENV['DUMP'] == 'true', valid_authorization_request_ids: })

    %i[warned skipped].each do |kind|
      export(kind)
      print_stats(kind)
    end
  end

  private

  def types_to_import
    %w[
    ]
  end

  def import(klass_name, options = {})
    if authorization_request_ids.any?
      options[:authorization_request_ids] = authorization_request_ids

      options[:authorization_requests_sql_where] = "id IN (#{authorization_request_ids.join(',')})"
      options[:users_sql_where] = "id IN (select user_id from events where authorization_request_id IN (#{authorization_request_ids.join(',')})) or id IN (select user_id from enrollments where id IN(#{authorization_request_ids.join(',')}))"
      options[:authorization_request_events_sql_where] = "authorization_request_id IN (#{authorization_request_ids.join(',')})"
    end

    Import.const_get(klass_name.to_s.classify << 's').new(global_options.merge(options)).perform
  end

  def export(kind)
    return unless ENV['LOCAL'] == 'true'

    data = public_send(kind)
    CSV.open(export_path(kind), 'w') do |csv|
      csv << %w[id target_api kind]

      data.each do |datum|
        csv << [datum.id, datum.target_api, datum.kind]
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
        %w[
        ].exclude?(enrollment_row['id'])
      end,
      authorization_requests_sql_where: 'target_api in (\'api_impot_particulier_sandbox\') order by id desc',
      # authorization_requests_sql_where: 'target_api not in (\'hubee_portail\', \'hubee_portail_dila\', \'api_entreprise\', \'api_particulier\') order by id desc',
      skipped: @skipped,
      warned: @warned,
    }
  end
end
