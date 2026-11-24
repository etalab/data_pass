RSpec.describe Molecules::PublicRegistry::AuthorizationHeaderComponent, type: :component do
  subject(:page_content) { render_inline(described_class.new(**params)) }

  let(:params) { { denomination: 'Ville de Clamart', origin: 'datapass' } }

  it 'renders the status badge then the origin badge in a DSFR badges group' do
    badges = page_content.css('ul.fr-badges-group > li > p.fr-badge')

    expect(badges.map { |badge| badge.text.strip }).to eq(['Active', 'Habilitation DataPass'])
    expect(badges.first[:class]).to include('fr-badge--success', 'fr-badge--sm')
    expect(badges.last[:class]).to include('fr-badge--sm', 'fr-badge--blue-ecume', 'fr-badge--no-icon')
  end

  it 'renders the denomination alone as the page title' do
    expect(page_content).to have_css('h1.fr-h2', exact_text: 'Ville de Clamart')
  end

  context 'when the denomination is blank' do
    let(:params) { { denomination: nil, origin: 'datapass' } }

    it 'shows « Non renseigné »' do
      expect(page_content).to have_css('h1', exact_text: 'Non renseigné')
    end
  end

  context 'with the European wallet origin' do
    let(:params) { { denomination: 'Ville de Clamart', origin: 'portefeuille-europeen' } }

    it 'renders the purple origin badge' do
      expect(page_content).to have_css('p.fr-badge--purple-glycine', text: 'Partie utilisatrice du portefeuille européen')
    end
  end

  context 'without an origin' do
    it 'raises an ArgumentError' do
      expect { described_class.new(denomination: 'Ville de Clamart') }.to raise_error(ArgumentError, /origin/)
    end
  end
end
