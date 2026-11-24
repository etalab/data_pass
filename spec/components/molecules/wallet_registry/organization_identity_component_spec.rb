RSpec.describe Molecules::WalletRegistry::OrganizationIdentityComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new(authorization_request:)) }

  let(:authorization_request) { build(:authorization_request, :registre_wallet, organization:) }
  let(:organization) { create(:organization, siret:) }

  context 'with a municipality' do
    let(:siret) { '21920023500014' }

    it 'shows the identity read from the INSEE data' do
      expect(rendered).to have_css('.wx-org__name', text: 'COMMUNE DE CLAMART')
      expect(rendered).to have_css('dd', text: '219 200 235 00014')
      expect(rendered).to have_css('dd', text: 'FR')
      expect(rendered).to have_css('dd', text: 'Oui, d’après la catégorie juridique (Commune)')
      expect(rendered).to have_css('dd', text: '1 place Maurice Gunsbourg, 92140 Clamart')
    end

    it 'sums up the legal form and the activity in one line' do
      expect(rendered).to have_css('p', text: 'Commune · 84.11Z, administration publique générale')
    end

    it 'shows the connected agent badge' do
      expect(rendered).to have_css('.fr-badge', text: 'Agent connecté par ProConnect')
    end

    it 'never asks a public agent to verify an executive status' do
      render_inline(described_class.new(authorization_request:, executive_certified: false))

      expect(page).to have_css('.fr-badge', text: 'Agent connecté par ProConnect')
      expect(page).to have_no_css('.fr-badge--warning')
    end

    it 'shows no European unique identifier yet' do
      expect(rendered).to have_no_css('dt', text: 'EUID')
    end
  end

  context 'with a company' do
    let(:siret) { '32816124500027' }

    it 'shows no VAT number, and no badge' do
      expect(rendered).to have_no_css('dt', text: 'TVA')
      expect(rendered).to have_no_css('.fr-badge--info')
    end

    it 'says it is not a public sector body' do
      expect(rendered).to have_css('dd', text: 'Non, d’après la catégorie juridique (SAS)')
    end

    context 'when the applicant is a certified executive' do
      subject(:rendered) { render_inline(described_class.new(authorization_request:, executive_certified: true)) }

      it 'shows the certified executive badge, without the verification button' do
        expect(rendered).to have_css('.fr-badge--info', text: 'Certifié dirigeant par ProConnect')
        expect(rendered).to have_no_button('Vérifier que je dirige l’organisation')
      end
    end

    context 'when the executive certification expired or was abandoned' do
      subject(:rendered) { render_inline(described_class.new(authorization_request:, executive_certified: false)) }

      it 'says the verification is to do and offers to launch it' do
        expect(rendered).to have_css('.fr-badge--warning', text: 'Vérification de dirigeant à faire')
        expect(rendered).to have_button('Vérifier que je dirige l’organisation')
      end
    end
  end

  context 'with a non diffusible establishment whose address Sirene gives (fixture : forme supposée de la réponse 3.11 privée, non vérifiée sur un vrai SIRET)' do
    let(:siret) { '12345678900023' }

    it 'shows the address to the applicant' do
      expect(rendered).to have_css('dd', text: '12 rue des Cyclistes, 69003 Lyon 3e Arrondissement')
    end
  end

  context 'with a non diffusible establishment whose address is withheld as « [ND] »' do
    let(:siret) { '12345678900015' }

    it 'does not show the address' do
      expect(rendered).to have_no_css('dt', text: 'Adresse d’établissement')
    end
  end

  context 'when Sirene did not answer' do
    let(:siret) { '21920023500022' }
    let(:organization) { create(:organization, siret:).tap { |org| org.update!(insee_payload: nil) } }

    it 'only shows the SIRET from the connection and the country code' do
      expect(rendered).to have_css('dt', text: 'Numéro de SIRET (connexion ProConnect)')
      expect(rendered).to have_no_css('.wx-org__head')
    end
  end
end
