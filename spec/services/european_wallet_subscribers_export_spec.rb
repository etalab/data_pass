RSpec.describe EuropeanWalletSubscribersExport do
  subject(:rows) { CSV.parse(described_class.new(profile: 'intermediary').to_csv, headers: true) }

  before do
    create(:european_wallet_subscriber, email: 'editeur@example.com', profile: 'intermediary', created_at: Time.zone.local(2026, 11, 16))
    create(:european_wallet_subscriber, email: 'mairie@example.com', profile: 'organization')
  end

  it 'exports only the subscribers of the profile' do
    expect(rows.pluck('email')).to eq(['editeur@example.com'])
  end

  it 'gives the profile as the contact list expects it, and the subscription date' do
    expect(rows.first.to_h).to include('profil' => 'intermediaire', 'date_inscription' => '2026-11-16')
  end

  it 'neutralizes an address a spreadsheet would read as a formula' do
    create(:european_wallet_subscriber, email: '=1+2@example.com', profile: 'intermediary')

    expect(rows.pluck('email')).to include("'=1+2@example.com")
  end

  it 'refuses an unknown profile' do
    expect { described_class.new(profile: 'particulier').to_csv }.to raise_error(KeyError)
  end
end
