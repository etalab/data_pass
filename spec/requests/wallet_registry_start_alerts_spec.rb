RSpec.describe 'Alerts on the wallet registry start page' do
  let(:failure_title) { 'La connexion a échoué. Veuillez réessayer.' }

  before { get '/auth/failure' }

  it 'shows the alerts once on the definition path, where the layout renders them' do
    get '/demandes/registre-wallet/nouveau?eligibility_confirmed=true&parcours=agent'

    expect(response.body.scan(failure_title).size).to eq(1)
  end

  it 'shows the alerts once on the form path, where the start block renders them' do
    get '/formulaires/registre-wallet/demande/nouveau?parcours=agent'

    expect(response.body.scan(failure_title).size).to eq(1)
  end
end
