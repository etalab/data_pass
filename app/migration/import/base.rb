class Import::Base
  include ImportUtils

  attr_reader :options

  def initialize(options = {})
    @options = options
    @models = []
  end

  def perform
    log("# Importing #{model_tableize}...")

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

    @models
  end

  protected

  def export
    fail NoImplementedError
  end

  def csv_to_loop
    csv(model_tableize)
  end

  private

  def model_name
    self.class.name.split('::')[-1]
  end

  def model_tableize
    model_name.underscore.pluralize
  end

  def import?(row)
    true
  end

  def sanitize_user_organizations(organizations)
    json = organizations
      .gsub('{"{', '[{')
      .gsub('}"}', '}]')
      .gsub('\\"', '"')
      .gsub('","', ',')

    JSON.parse(json)
  end

  def to_boolean(value)
    value == 't' ||
      value == 'true'
  end
end
