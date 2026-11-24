RSpec.describe Molecules::PublicRegistry::OpeningAlertComponent, type: :component do
  subject(:page_content) { render_inline(described_class.new(wallet_page_url: '/portefeuille-europeen')) }

  it 'renders an information alert with a level 2 title announcing the opening date' do
    expect(page_content).to have_css('div.fr-alert.fr-alert--info h2.fr-alert__title', text: 'Le registre des parties utilisatrices du portefeuille européen ouvre le 24 décembre 2026')
  end

  it 'says what the registry will publish and links to the European wallet page' do
    expect(page_content).to have_css('div.fr-alert p', text: /Les organisations enregistrées y figureront/)
    expect(page_content).to have_link('Découvrir le registre du portefeuille européen', href: '/portefeuille-europeen', class: 'fr-link')
  end
end
