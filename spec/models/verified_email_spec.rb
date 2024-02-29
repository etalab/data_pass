RSpec.describe VerifiedEmail do
  it 'has valid factory' do
    expect(build(:verified_email)).to be_valid
  end
end
