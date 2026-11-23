RSpec.describe Molecules::WalletRegistry::IntendedUseHeaderComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new(use:, title_id: 'usage-title', body_id: 'usage-body')) }

  let(:authorization_request) { create(:authorization_request, :registre_wallet, fill_all_attributes: true) }
  let(:use) { authorization_request.wallet_intended_uses.first }

  it 'names the use and sums up its checked data' do
    expect(rendered).to have_css('h3#usage-title', text: 'Vérifier la majorité')
    expect(rendered).to have_text('1 attestation, 1 donnée')
    expect(rendered).to have_css('.att-summary li', text: 'Permis de conduire mobile : plus de 18 ans')
  end

  it 'deletes the use after a confirmation, and folds the card' do
    expect(rendered).to have_css("button[aria-controls='wallet-delete-use-#{use.id}'][data-fr-opened='false']", text: 'Supprimer')
    expect(rendered).to have_css('button[aria-controls="usage-body"][aria-expanded="true"]', text: 'Replier')
  end

  context 'when no data is checked' do
    before { use.attestations.first.selected_claim_ids = [] }

    it 'leaves the summary empty' do
      expect(rendered).to have_no_css('.att-summary li')
    end
  end
end
