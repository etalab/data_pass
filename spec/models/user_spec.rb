RSpec.describe User do
  it 'has valid factories' do
    expect(build(:user)).to be_valid
  end
end
