require 'csv'

class MainImport
  include ImportUtils

  def perform
    organizations = import(:organizations, { load_from_sql: true })
    users = import(:users, { organizations:, load_from_sql: true })
    import(:authorization_requests, { users: })
  end

  private

  def import(klass_name, options = {})
    Import.const_get(klass_name.to_s.classify << 's').new(options.merge(global_options)).perform
  end

  def global_options
    {
      authorization_requests_filter: ->(enrollment_row) { sample_hubee_cert_dc_enrollment_ids.include?(enrollment_row['id'].to_i) },
    }
  end

  def sample_hubee_cert_dc_enrollment_ids
    [9677, 18772, 20168, 22942, 27436, 27734, 28471, 35800, 36888, 42636, 45824, 50077, 50937, 51511, 53359, 53749]
  end
end
