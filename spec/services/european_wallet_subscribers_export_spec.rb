RSpec.describe EuropeanWalletSubscribersExport do
  subject(:rows) { CSV.parse(described_class.new(profile: 'intermediary', host: 'https://datapass.example').to_csv, headers: true) }

  let!(:intermediary) { create(:european_wallet_subscriber, email: 'editeur@example.com', profile: 'intermediary', created_at: Time.zone.local(2026, 11, 16)) }

  before { create(:european_wallet_subscriber, email: 'mairie@example.com', profile: 'organization') }

  it 'exports only the subscribers of the profile' do
    expect(rows.pluck('email')).to eq(['editeur@example.com'])
  end

  it 'gives the profile as the contact list expects it, and the subscription date' do
    expect(rows.first.to_h).to include('profil' => 'intermediaire', 'date_inscription' => '2026-11-16')
  end

  it 'gives an unsubscribe link that finds the subscriber back' do
    token = Rack::Utils.parse_query(URI(rows.first['lien_desinscription']).query)['token']

    expect(rows.first['lien_desinscription']).to start_with('https://datapass.example/portefeuille-europeen/desinscription?token=')
    expect(EuropeanWalletSubscriber.find_by_token_for(:unsubscribe, token)).to eq(intermediary)
  end

  it 'refuses an unknown profile' do
    expect { described_class.new(profile: 'particulier').to_csv }.to raise_error(KeyError)
  end
end
