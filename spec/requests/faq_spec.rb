RSpec.describe 'FAQ page' do
  it 'lists a form whose feature flag is on' do
    get '/faq'

    expect(response.body).to include('Registre des parties utilisatrices du wallet')
  end

  it 'hides a form whose feature flag is off' do
    allow(FeatureFlag).to receive(:enabled?).and_call_original
    allow(FeatureFlag).to receive(:enabled?).with('registre_wallet').and_return(false)

    get '/faq'

    expect(response.body).not_to include('Registre des parties utilisatrices du wallet')
  end
end
