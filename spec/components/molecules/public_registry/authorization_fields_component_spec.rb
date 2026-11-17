RSpec.describe Molecules::PublicRegistry::AuthorizationFieldsComponent, type: :component do
  subject(:page_content) { render_inline(described_class.new(entry: Molecules::PublicRegistry::AuthorizationEntry.new(**params))) }

  let(:params) do
    {
      denomination: 'Ville de Clamart',
      siret: '21920023500014',
      service: 'APIParticulier',
      provider: 'DINUM',
      scopes: %w[cnaf_quotient_familial cnaf_enfants],
      legal_basis: 'Code de l’action sociale et des familles, article L. 123-5',
      validated_on: Date.new(2026, 7, 2),
      number: 'H44120',
    }
  end

  it 'renders the eight fields in order in a definition list' do
    terms = page_content.css('dl > div.fr-grid-row > dt').map { |term| term.text.strip }

    expect(terms).to eq(['Organisation habilitée', 'SIRET', 'API ou service', 'Fournisseur', 'Données demandées', 'Fondement juridique', 'Date de validation', 'Numéro au registre'])
  end

  it 'renders the values' do
    definitions = page_content.css('dl dd').map { |definition| definition.text.strip }

    expect(definitions).to eq(['Ville de Clamart', '21920023500014', 'APIParticulier', 'DINUM', 'cnaf_quotient_familial, cnaf_enfants', 'Code de l’action sociale et des familles, article L. 123-5', '02/07/2026', 'H44120'])
  end

  it 'lays out terms and definitions on the DSFR grid' do
    expect(page_content).to have_css('dt.fr-col-12.fr-col-sm-4.fr-text--sm.fr-text--bold.fr-text-mention--grey', count: 8)
    expect(page_content).to have_css('dd.fr-col-12.fr-col-sm-8', count: 8)
  end

  it 'lets only the service and the scopes break anywhere' do
    expect(page_content.css('dd.r-code').map { |definition| definition.text.strip }).to eq(['APIParticulier', 'cnaf_quotient_familial, cnaf_enfants'])
  end

  context 'when fields are blank' do
    let(:params) { super().merge(scopes: [], legal_basis: nil, denomination: '') }

    it 'shows « Non renseigné » in grey' do
      expect(page_content).to have_css('dd span.fr-text-mention--grey', text: 'Non renseigné', count: 3)
    end
  end
end
