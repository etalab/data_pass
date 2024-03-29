require 'csv'

class MainImport
  include ImportUtils

  def initialize
    @skipped = []
  end

  def perform
    organizations = import(:organizations, { load_from_sql: true })
    import(:users, { load_from_sql: true })
    import(:authorization_requests)

    export_skipped
    print_skipped_stats
  end

  private

  def import(klass_name, options = {})
    Import.const_get(klass_name.to_s.classify << 's').new(options.merge(global_options)).perform
  end

  def export_skipped
    log("# Skipped: #{@skipped.count}")

    CSV.open(export_path, 'w') do |csv|
      csv << %w[id target_api kind]

      @skipped.each do |skipped|
        csv << [skipped.id, skipped.target_api, skipped.kind]
      end
    end
  end

  def print_skipped_stats
    log('Skipped stats:')

    log('  - by target_api:')
    @skipped.group_by(&:target_api).each do |target_api, skipped|
      log("  #{target_api}: #{skipped.count}")
    end

    log('  - by error type:')
    @skipped.group_by(&:kind).each do |kind, skipped|
      log("  #{kind}: #{skipped.count}")
    end
  end

  def export_path
    Rails.root.join('app/migration/dumps/skipped.csv')
  end

  def global_options
    {
      skipped: @skipped,
    }
  end
end
