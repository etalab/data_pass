RSpec.describe Molecules::PublicRegistry::SearchBarComponent, type: :component do
  subject(:page_content) { render_inline(described_class.new(**params)) }

  let(:params) { { url: '/registre-public' } }

  it 'renders a DSFR search form sent with GET' do
    expect(page_content).to have_css('form[role="search"][method="get"][action="/registre-public"] div.fr-search-bar')
  end

  it 'labels the search field with the button text as placeholder' do
    expect(page_content).to have_css('label.fr-label[for="public-registry-search"]', text: 'Rechercher')
    expect(page_content).to have_field('Rechercher', type: 'search', placeholder: 'Rechercher', class: 'fr-input', name: 'q', id: 'public-registry-search')
    expect(page_content).to have_button('Rechercher')
  end

  it 'shows the help text below the bar and links it to the field' do
    expect(page_content).to have_css('input[aria-describedby="public-registry-search-hint"]')
    expect(page_content).to have_css('p#public-registry-search-hint.fr-text--sm.fr-text-mention--grey', exact_text: 'Une organisation, un SIRET ou un SIREN, une API ou un service, un fournisseur, un numéro')
  end

  it 'has no origin field without filter' do
    expect(page_content).to have_no_field('origine', type: :hidden, visible: :hidden)
  end

  context 'with a query and selected origins' do
    let(:params) { { url: '/registre-public', query: 'clamart', origins: %w[portefeuille-europeen datapass] } }

    it 'keeps the query in the field' do
      expect(page_content).to have_field('q', with: 'clamart')
    end

    it 'keeps the origins in a hidden field, in a stable order' do
      expect(page_content).to have_css('input[type="hidden"][name="origine"][value="datapass,portefeuille-europeen"]', visible: :hidden)
    end
  end
end
