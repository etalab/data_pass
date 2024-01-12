require 'csv'

class MainImport
  include ImportUtils

  def perform
    organizations = import(:organizations, { load_from_sql: true })
    users = import(:users, { organizations:, dump_sql: true })
    # authorization_requests = import(:authorization_requests, { users: })
  end

  private

  def import(klass_name, options = {})
    Import.const_get(klass_name.to_s.classify << 's').new(options.merge(global_options)).perform
  end

  def global_options
    {
      # users_filter: ->(user_row) { sample_hubee_cert_dc_user_ids.include?(user_row['id'].to_i) },
      enrollments_filter: ->(enrollment_row) { sample_hubee_cert_dc_enrollment_ids.include?(enrollment_row['id'].to_i) },
    }
  end

  def sample_hubee_cert_dc_user_ids
    [20656, 17349, 30617, 33092, 37926, 16301, 39024, 22469, 47110, 53803, 56732, 53213, 22965, 39014, 29505, 64640]
  end

  def sample_hubee_cert_dc_enrollment_ids
    [9677, 18772, 20168, 22942, 27436, 27734, 28471, 35800, 36888, 42636, 45824, 50077, 50937, 51511, 53359, 53749]
  end
end
