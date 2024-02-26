RSpec.describe AuthorizationDocument do
  it 'has valid factories' do
    expect(build(:authorization_document)).to be_valid
  end
end
