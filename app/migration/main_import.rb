require 'csv'

class MainImport
  include ImportUtils

  attr_reader :skipped, :warned

  def initialize
    @skipped = []
    @warned = []
  end

  def perform
    organizations = import(:organizations, { load_from_sql: true })
    import(:users, { load_from_sql: true })
    authorization_requests = import(:authorization_requests, { dump_sql: true })

    # import(:authorization_request_events, { dump_sql: true, valid_authorization_request_ids: authorization_requests.pluck(:id) })

    %i[warned skipped].each do |kind|
      export(kind)
      print_stats(kind)
    end
  end

  private

  def import(klass_name, options = {})
    Import.const_get(klass_name.to_s.classify << 's').new(options.merge(global_options)).perform
  end

  def export(kind)
    data = public_send(kind)
    log("# #{kind}: #{data.count}")

    CSV.open(export_path(kind), 'w') do |csv|
      csv << %w[id target_api kind]

      data.each do |datum|
        csv << [datum.id, datum.target_api, datum.kind]
      end
    end
  end

  def print_stats(kind)
    data = public_send(kind)
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
          5
          26
          129
          25590
          54115
        ].exclude?(enrollment_row['id'])
      end,
      authorization_requests_sql_where: 'target_api = \'api_particulier\'',
      skipped: @skipped,
      warned: @warned,
    }
  end

  def authorization_request_ids
    @authorization_request_ids ||= @authorization_requests.map(&:id)
  end
end
