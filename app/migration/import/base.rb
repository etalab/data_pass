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
    options[:load_from_sql] == true
  end

  def load_sql_file!
    log("# Importing #{model_tableize} from SQL dump")

    model_klass.delete_all

    `psql -d #{ActiveRecord::Base.connection.current_database} -f #{sql_file_path}`

    log("> DONE")

    model_klass.all
  end

  def dump_sql_file!
    log("# Dumping #{model_tableize} to SQL file")

    `pg_dump -d #{ActiveRecord::Base.connection.current_database} -t #{model_tableize} > #{sql_file_path}`

    log("> SQL file dumped")
  end

  def load_from_csv!
    log("# Importing #{model_tableize} from CSV file")

    csv_to_loop.each do |row|
      next unless import?(row)

      begin
        extract(row)
      rescue => e
        log(" ERROR: #{e.message}")
        log(e.backtrace.join("\n"))

        byebug if ENV['LOCAL'].present?
      end
    end

    log(" > #{@models.count} #{model_tableize} imported")

    dump_sql_file! if options[:dump_sql]

    @models
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

  def sql_file_path
    Rails.root.join("app/migration/dumps/#{model_tableize}.sql")
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
