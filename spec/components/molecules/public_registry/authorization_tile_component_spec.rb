RSpec.describe Molecules::PublicRegistry::AuthorizationTileComponent, type: :component do
  subject(:page_content) { render_inline(described_class.new(url: '/registre-public/H44120', entry:, origin:)) }

  let(:origin) { 'datapass' }
  let(:entry_values) do
    {
      denomination: 'Ville de Clamart',
      service: 'APIParticulier',
      provider: 'DINUM',
      validated_on: Date.new(2026, 7, 2),
      number: 'H44120',
    }
  end
  let(:entry) { Molecules::PublicRegistry::AuthorizationEntry.new(**entry_values) }

  it 'renders a horizontal DSFR tile with a level 2 title linking to the authorization' do
    expect(page_content).to have_css('div.fr-tile.fr-tile--horizontal.fr-enlarge-link.r-code h2.fr-tile__title a.fr-tile__link[href="/registre-public/H44120"]')
  end

  it 'adds the service to the link text for screen readers only' do
    expect(page_content).to have_css('a.fr-tile__link', text: 'Ville de Clamart · APIParticulier')
    expect(page_content).to have_css('a.fr-tile__link span.fr-sr-only', text: '· APIParticulier')
  end

  it 'renders the status badge before the origin badge' do
    badges = page_content.css('.fr-tile__start p.fr-badge')

    expect(badges.map { |badge| badge.text.strip }).to eq(['Active', 'Habilitation DataPass'])
    expect(badges.first[:class]).to include('fr-badge--success', 'fr-badge--sm')
    expect(badges.last[:class]).to include('fr-badge--sm', 'fr-badge--blue-ecume', 'fr-badge--no-icon')
  end

  it 'renders the details line with screen reader labels' do
    expect(page_content).to have_css('p.fr-tile__desc', text: 'API ou service : APIParticulier · Fournisseur : DINUM · Validée le 02/07/2026 · H44120')
    expect(page_content).to have_css('p.fr-tile__desc span.fr-sr-only', text: 'API ou service :')
    expect(page_content).to have_css('p.fr-tile__desc span.fr-sr-only', text: 'Fournisseur :')
  end

  context 'when the denomination is blank' do
    let(:entry_values) { super().merge(denomination: '') }

    it 'shows « Non renseigné » as the link text' do
      expect(page_content).to have_css('a.fr-tile__link', text: 'Non renseigné · APIParticulier')
    end
  end

  context 'when values contain HTML' do
    let(:entry_values) { super().merge(denomination: '<script>alert(1)</script>', provider: '<b>DINUM</b>') }

    it 'escapes them' do
      expect(page_content).to have_no_css('script')
      expect(page_content).to have_no_css('b')
      expect(page_content).to have_text('<script>alert(1)</script>')
    end
  end

  context 'with the European wallet origin' do
    let(:origin) { 'portefeuille-europeen' }

    it 'renders the purple origin badge' do
      expect(page_content).to have_css('p.fr-badge.fr-badge--purple-glycine.fr-badge--no-icon', text: 'Partie utilisatrice du portefeuille européen')
    end
  end

  context 'with an unknown origin' do
    it 'raises an ArgumentError' do
      expect { described_class.new(url: '#', entry:, origin: 'wallet') }.to raise_error(ArgumentError, /origin must be one of/)
    end
  end
end
