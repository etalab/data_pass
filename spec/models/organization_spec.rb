RSpec.describe Organization do
  it 'has valid factories' do
    expect(build(:organization)).to be_valid
  end
end
