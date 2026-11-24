RSpec.describe Molecules::WalletRegistry::OrganizationSummaryComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new(authorization_request:)) }

  let(:organization) { create(:organization, siret: '21920023500014') }
  let(:authorization_request) { build(:authorization_request, :registre_wallet, organization:, wallet_privacy_policy_url: 'https://www.clamart.fr/confidentialite', wallet_support_email: 'contact@clamart.fr', wallet_support_phone: '0146629000', wallet_not_registered_elsewhere: true) }

  it 'groups the identification and the information for users' do
    expect(rendered).to have_css('h3', text: 'Identification')
    expect(rendered).to have_css('h3', text: 'Informations pour les usagers')
  end

  it 'reads each information as a small grey label followed by its value' do
    expect(rendered).to have_css('.contact-card__attribute-label', text: 'Nom officiel')
    expect(rendered).to have_css('.contact-card__attribute-value', text: 'COMMUNE DE CLAMART')
    expect(rendered).to have_css('.contact-card__attribute-value', text: '219 200 235 00014')
    expect(rendered).to have_css('.contact-card__attribute-value', text: 'Oui, d’après la catégorie juridique (Commune)')
    expect(rendered).to have_css('.contact-card__attribute-value', text: '1 place Maurice Gunsbourg, 92140 Clamart')
    expect(rendered).to have_css('.contact-card__attribute-value', text: 'Déclarée')
  end

  it 'lays out the information for users on two columns' do
    expect(rendered).to have_css('.fr-col-md-6 .contact-card__attribute-label', text: 'Politique de confidentialité par défaut')
    expect(rendered).to have_css('.fr-col-md-6 .contact-card__attribute-value', text: 'contact@clamart.fr')
  end

  it 'shows the support phone by pairs of digits' do
    expect(rendered).to have_css('.contact-card__attribute-value', text: '01 46 62 90 00')
  end

  it 'does not repeat the panel of the step: no icon, no badge' do
    expect(rendered).to have_no_css('.fr-badge')
    expect(rendered).to have_no_css('.wx-org__icon')
  end

  context 'with a non diffusible establishment (fixture : forme supposée de la réponse 3.11 privée, non vérifiée sur un vrai SIRET)' do
    let(:organization) { create(:organization, siret: '12345678900023') }

    it 'shows the address read in Sirene, saying it is not published' do
      expect(rendered).to have_css('.contact-card__attribute-value', text: /12 rue des Cyclistes, 69003 Lyon 3e Arrondissement\s*Non publiée : votre établissement n’est pas diffusible\./)
    end
  end

  describe 'public sector line' do
    def public_sector_value
      rendered
      page.find(:xpath, "//div[contains(@class, 'contact-card__attribute-label')][normalize-space() = 'Organisme du secteur public']/following-sibling::div").text.strip
    end

    it 'says yes for a municipality, with the reason' do
      expect(public_sector_value).to eq('Oui, d’après la catégorie juridique (Commune)')
    end

    context 'with a company' do
      let(:organization) { create(:organization, siret: '32816124500027') }

      it 'says no, with the reason' do
        expect(public_sector_value).to start_with('Non, d’après la catégorie juridique')
      end
    end

    context 'when the classification is not known' do
      let(:authorization_request) { build(:authorization_request, :registre_wallet, organization:).tap { |request| request.identity_public_sector = nil } }

      it 'says it is not filled, without any reason' do
        expect(public_sector_value).to eq('Non renseigné')
      end
    end

    context 'when the identity is still loading' do
      let(:authorization_request) do
        build(:authorization_request, :registre_wallet, organization:).tap do |request|
          request.assign_attributes(identity_source: 'sirene_pending', identity_legal_name: nil, identity_address: nil, identity_public_sector: nil)
        end
      end

      it 'says it is loading' do
        expect(public_sector_value).to eq('En cours de chargement')
      end
    end
  end

  context 'when the identity is still loading' do
    let(:authorization_request) { build(:authorization_request, :registre_wallet, organization:, identity_source: 'sirene_pending', identity_legal_name: nil, identity_address: nil) }

    it 'says the name and the address are loading, instead of the SIRET' do
      expect(rendered).to have_css('.contact-card__attribute-value', text: 'En cours de chargement', count: 3)
      expect(rendered).to have_no_text('nom inconnu')
    end
  end

  context 'when Sirene did not answer' do
    let(:authorization_request) { build(:authorization_request, :registre_wallet, organization:, identity_source: 'sirene_unavailable', identity_legal_name: nil, identity_address: nil) }

    it 'says the name and the address are not filled, without the public sector line' do
      expect(rendered).to have_css('.contact-card__attribute', text: /Nom officiel\s*Non renseigné/)
      expect(rendered).to have_css('.contact-card__attribute', text: /Adresse d’établissement\s*Non renseigné/)
      expect(rendered).to have_no_css('.contact-card__attribute-label', text: 'Organisme du secteur public')
      expect(rendered).to have_no_text('nom inconnu')
    end
  end
end
