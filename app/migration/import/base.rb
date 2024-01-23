class Import::Base
  include ImportUtils

  attr_reader :options

  def initialize(options = {})
    @options = options
    @models = []
  end

  def perform
    if import_from_sql?
      load_sql_file!
    else
      load_from_csv!
    end
  end

  protected

  def export
    fail NoImplementedError
  end

  def csv_to_loop
    csv(model_tableize)
  end

  def import?(row)
    true
  end

  private

  def import_from_sql?
    options[:load_from_sql] &&
      sql_tables_to_save.all? { |sql_table| File.exist?(sql_file_path(sql_table)) }
  end

  def load_sql_file!
    model_klass.destroy_all

    sql_tables_to_save.each do |sql_table|
      log("# Importing #{sql_table} from SQL dump")

      `psql -d #{ActiveRecord::Base.connection.current_database} -f #{sql_file_path(sql_table)}`
    end

    log("> DONE")

    model_klass.all
  end

  def dump_sql_file!
    sql_tables_to_save.each do |sql_table|
      log("# Dumping #{sql_table} to SQL file")

      `pg_dump -a -d #{ActiveRecord::Base.connection.current_database} -t #{sql_table} > #{sql_file_path(sql_table)}`
    end

    log("> SQL file dumped")
  end

  def load_from_csv!
    log("# Importing #{model_tableize} from CSV file")

    csv_to_loop.each do |row|
      next unless match_global_filter?(row)
      next unless import?(row)

      begin
        extract(row)
        print '.'
      rescue Import::AuthorizationRequests::Base::SkipRow => e
        options[:skipped] << e
      rescue => e
        log(" ERROR: #{e.message}")
        log(e.backtrace.join("\n"))

        byebug if ENV['LOCAL'].present?
      end
    end

    log(" > #{@models.count} #{model_tableize} imported")

    dump_sql_file! if options[:dump_sql] || options[:load_from_sql]

    @models
  end

  def match_global_filter?(row)
    filter_key = "#{model_tableize}_filter".to_sym

    options[filter_key].blank? ||
      options[filter_key].call(row)
  end

  def model_klass
    model_tableize.classify.constantize
  end

  def model_name
    self.class.name.split('::')[-1]
  end

  def model_tableize
    model_name.underscore.pluralize
  end

  def sql_file_path(sql_table)
    Rails.root.join("app/migration/dumps/#{sql_table}.sql")
  end

  def sql_tables_to_save
    [model_tableize]
  end

  def sanitize_user_organizations(organizations)
    json = organizations
      .gsub('{"{', '[{')
      .gsub('}"}', '}]')
      .gsub('\\"', '"')
      .gsub('","', ',')
      .gsub('\\"', '"')

    JSON.parse(json)
  rescue => e
    byebug
  end

  def to_boolean(value)
    value == 't' ||
      value == 'true'
  end
end
