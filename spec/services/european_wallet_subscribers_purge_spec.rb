RSpec.describe EuropeanWalletSubscribersPurge do
  before do
    create_list(:european_wallet_subscriber, 2, profile: 'organization')
    create(:european_wallet_subscriber, profile: 'intermediary')
  end

  it 'deletes the subscribers of the profile only and tells how many' do
    expect(described_class.new(profile: 'organization').call).to eq(2)

    expect(EuropeanWalletSubscriber.pluck(:profile)).to eq(['intermediary'])
  end

  it 'refuses an unknown profile' do
    expect { described_class.new(profile: 'particulier') }.to raise_error(KeyError)
  end
end
