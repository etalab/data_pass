RSpec.describe AuthorizationRequest do
  it 'has valid factories' do
    %w[
      hubee_cert_dc
      api_entreprise
      api_particulier
      api_infinoe_sandbox
      api_infinoe_production
      api_service_national
    ].each do |kind|
      authorization_request = build(:authorization_request, kind, state: 'submitted')
      authorization_request.save!
      authorization_request.state = 'draft'
      authorization_request.save!
    rescue StandardError => e
      fail "Factory :authorization_request, kind: #{kind}, state: 'submitted' is not valid: #{e}"
    end

    AuthorizationRequest.state_machine.states.map(&:name).each do |state|
      expect(build(:authorization_request, :api_entreprise, state)).to be_valid
    end
  end
end
