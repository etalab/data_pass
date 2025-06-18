RSpec.describe VerifiedEmail do
  it 'has valid factory' do
    expect(build(:verified_email)).to be_valid
  end

  it 'normalizes email to downcase and trimmed' do
    expect(described_class.new(email: 'toTO@example.com    ').email).to eq('toto@example.com')
  end
end
