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

    # import(:authorization_request_events, { dump_sql: ENV['DUMP'] == 'true', valid_authorization_request_ids: })

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
      csv << %w[id target_api kind url]

      data.each do |datum|
        csv << [datum.id, datum.target_api, datum.kind, "https://datapass.api.gouv.fr/#{datum.target_api.gsub('_', '-')}/#{datum.id}"]
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
          64447 64348 62067 6195 6033 5055 4438 4436 4433 4198 4166 4162 4159 4157 4155
          4153 4151 4149 4147 4145 4143 4140 4138 4136 4134 4132 4130 4127 4125 4123
          4121 4119 4117 4115 4113 4109 4106 4104 4101 4098 4096 4094 4092 4090 4088
          3932 3540 54510 54497 43297 40647 40116 39580 14323 51640 49730 49191 48323
          23657 14770 45463 45442 43965 43816 5893 4442 45173 3666
        ].exclude?(enrollment_row['id'])
        # %w[63955 64669].include?(enrollment_row['id'])
        true
      end,
      authorization_requests_sql_where: 'target_api in (\'franceconnect\') order by id',
      # authorization_requests_sql_where: 'target_api in (\'api_impot_particulier_sandbox\', \'api_impot_particulier_production\') order by case when target_api like \'%_sandbox\' then 1 else 2 end',
      skipped: @skipped,
      warned: @warned,
    }
  end
end
