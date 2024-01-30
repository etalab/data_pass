RSpec.describe Authorization do
  it 'has valid factories' do
    expect(build(:authorization)).to be_valid
  end
end
