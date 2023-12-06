RSpec.describe AuthorizationRequest do
  it 'has valid factories' do
    expect(build(:authorization_request)).to be_valid
    expect(build(:authorization_request, state: 'submitted')).to be_valid
  end
end
