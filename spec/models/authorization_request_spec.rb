RSpec.describe AuthorizationRequest do
  # rubocop:disable RSpec/NoExpectationExample
  it 'has valid factories' do
    %w[
      hubee_cert_dc
      api_entreprise
      api_infinoe_sandbox
      api_infinoe_production
    ].each do |kind|
      authorization_request = build(:authorization_request, kind, state: 'submitted')
      authorization_request.save!
      authorization_request.state = 'draft'
      authorization_request.save!
    rescue StandardError => e
      fail "Factory :authorization_request, kind: #{kind}, state: 'submitted' is not valid: #{e}"
    end
  end
  # rubocop:enable RSpec/NoExpectationExample
end
