require 'csv'

class MainImport
  include ImportUtils

  def perform
    log("Init")
    organizations = import(:organizations)
    users = import(:users, { organizations: })
  end

  private

  def import(klass_name, options = {})
    Import.const_get(klass_name.to_s.classify << 's').new(options.merge(global_options)).perform
  end

  def global_options
    {
      users_filter: ->(user_row) { sample_hubee_cert_dc_user_ids.include?(user_row['id'].to_i) },
    }
  end

  def sample_hubee_cert_dc_user_ids
    [62415, 62437, 62439, 62451, 62453, 62459, 62461, 62475, 62477, 62525]
  end
end
