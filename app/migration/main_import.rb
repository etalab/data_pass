require 'csv'

class MainImport
  include ImportUtils

  def initialize
    @skipped = []
  end

  def perform
    organizations = import(:organizations, { load_from_sql: true })
    import(:users, { organizations:, load_from_sql: true })
    import(:authorization_requests)

    print_skipped
  end

  private

  def import(klass_name, options = {})
    Import.const_get(klass_name.to_s.classify << 's').new(options.merge(global_options)).perform
  end

  def print_skipped
    log("# Skipped: #{@skipped.count}")

    @skipped.each do |skipped|
      log("#{skipped.to_json}")
    end
  end

  def global_options
    {
      skipped: @skipped,
    }
  end
end
