RSpec.describe Message do
  it 'has valid factories' do
    expect(build(:message)).to be_valid
    expect(build(:message, :system)).to be_valid
  end
end
