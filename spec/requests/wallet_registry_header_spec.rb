RSpec.describe 'Header tagline on the wallet registry pages' do
  def tagline
    response.parsed_body.at_css('.fr-header__service-tagline').text.squish
  end

  before { sign_in(create(:user)) }

  it 'keeps the tagline of the wallet registry for a signed in user' do
    get '/formulaires/registre-wallet/demande/nouveau'

    expect(tagline).to eq('Habilitations et registre du portefeuille européen')
  end

  it 'keeps the usual tagline on the other forms' do
    get '/formulaires/api-entreprise/demande/nouveau'

    expect(tagline).to eq('Habilitations juridiques')
  end
end
