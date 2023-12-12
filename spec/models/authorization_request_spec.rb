RSpec.describe AuthorizationRequest do
  it 'has valid factories' do
    %w[
      hubee_cert_dc
      api_entreprise
    ].each do |kind|
      expect(build(:authorization_request, kind)).to be_valid
      expect(build(:authorization_request, kind, state: 'submitted')).to be_valid
    end
  end
end
