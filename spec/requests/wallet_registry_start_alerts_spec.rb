RSpec.describe 'Alerts on the wallet registry start page' do
  let(:failure_title) { 'La connexion a échoué. Veuillez réessayer.' }

  before { get '/auth/failure' }

  it 'shows the alerts once on the definition path, the only page where the wallet registry start is shown' do
    get '/demandes/registre-wallet/nouveau?eligibility_confirmed=true&parcours=agent'

    expect(response.body.scan(failure_title).size).to eq(1)
  end
end
