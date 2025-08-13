require 'openapi3_parser'

module OpenAPIValidator
  def self.included(base)
    base.let(:open_api_definition) do
      OpenapiFirst.load('config/openapi/v1.yaml') do |config|
        config.path = ->(req) { req.path.sub('/api/v1', '') }
      end
    end
  end

  def validate_request_and_response!
    validate_request!
    validate_response!
  end

  def validate_request!
    validated_request = open_api_definition.validate_request(request)
    potential_errors = validated_request.error&.errors || []
    expect(validated_request).to be_valid, "Request validation failed: #{format_errors(potential_errors)}"
  end

  def validate_response!
    validated_response = open_api_definition.validate_response(request, response)
    potential_errors = validated_response.error&.errors || []
    expect(validated_response).to be_valid, "Response validation failed: #{format_errors(potential_errors)}"
  end

  def format_errors(errors)
    "\n#{errors.map(&:message).join("\n")}"
  end
end

RSpec.configure do |config|
  config.include OpenAPIValidator, type: :request
  config.include OpenapiFirst::Test::Methods, type: :request
end
