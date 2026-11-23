RSpec.describe Molecules::WalletRegistry::IntendedUsesSummaryComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new(authorization_request:, uses:)) }

  let(:authorization_request) { create(:authorization_request, :registre_wallet, fill_all_attributes: true) }
  let(:use) { authorization_request.wallet_intended_uses.first }
  let(:uses) { [use] }

  it 'repeats the purpose, the period, the privacy policy and the data of each use' do
    expect(rendered).to have_css('h3', text: 'Vérifier la majorité')
    expect(rendered).to have_css('.contact-card__attribute-value', text: 'Vérifier que vous avez plus de 18 ans avant de vous louer un vélo.')
    expect(rendered).to have_css('.contact-card__attribute-label', text: 'Période')
    expect(rendered).to have_css('.sum-usage__att', text: 'Permis de conduire mobile')
    expect(rendered).to have_css('.fr-tag', text: 'Plus de 18 ans')
  end

  it 'counts the registration certificates' do
    expect(rendered).to have_text('1 certificat d’enregistrement')
  end

  context 'when the use has its own privacy policy' do
    before { use.privacy_policy_url = 'https://www.clamart.fr/compte-client' }

    it 'shows it' do
      expect(rendered).to have_css('.contact-card__attribute-value', text: 'https://www.clamart.fr/compte-client')
    end
  end

  context 'without any use' do
    let(:uses) { [] }

    it 'says so' do
      expect(rendered).to have_text('Aucune utilisation prévue')
      expect(rendered).to have_no_css('.sum-usage')
    end
  end
end
