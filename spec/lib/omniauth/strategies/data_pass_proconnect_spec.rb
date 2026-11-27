RSpec.describe OmniAuth::Strategies::DataPassProconnect do
  let(:gem_strategy) { OmniAuth::Strategies::Proconnect }
  let(:gem_methods) { gem_strategy.instance_methods(false) + gem_strategy.private_instance_methods(false) }

  let(:overridden_gem_methods) do
    %i[
      callback_phase
      authorization_uri
      store_tokens!
      get_userinfo!
      store_new_state!
      current_state
      store_new_nonce!
    ]
  end

  let(:called_gem_methods) do
    %i[
      connection
      discovered_configuration
      exchange_authorization_code!
      other_phase
      end_session_uri
      engage_logout!
      on_logout_path?
    ]
  end

  it 'is built on the omniauth-proconnect version it was written against' do
    expect(Omniauth::Proconnect::VERSION).to eq('0.6.2')
  end

  it 'still finds in the gem every method it overrides or relies on' do
    expect(gem_methods).to include(*overridden_gem_methods, *called_gem_methods)
  end

  it 'keeps the strategy name of the gem, so paths and redirect_uri stay the same' do
    expect(described_class.default_options[:name]).to eq('proconnect')
  end

  it 'leaves the gem strategy untouched' do
    expect(gem_strategy.private_instance_methods(false)).not_to include(:fetch_verified_identity!)
  end
end
