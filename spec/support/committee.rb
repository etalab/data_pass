require 'committee/rails'

RSpec.configure do |config|
  config.include Committee::Rails::Test::Methods, type: :request

  config.add_setting :committee_options
  config.committee_options = {
    schema_path: Rails.root.join('config/openapi/v1.yaml').to_s,
    strict_reference_validation: true,
    prefix: '/api/v1'
  }
end
