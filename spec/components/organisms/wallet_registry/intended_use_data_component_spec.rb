RSpec.describe Organisms::WalletRegistry::IntendedUseDataComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new(use:, index: 0, focus_key:)) }

  let(:authorization_request) { create(:authorization_request, :registre_wallet, fill_all_attributes: true) }
  let(:use) { authorization_request.wallet_intended_uses.first }
  let(:focus_key) { nil }
  let(:pid) { WalletRegistry::Rulebook.available.find_by!(identifier: 'pid') }
  let(:add_button_id) { 'authorization_request_registre_wallet_wallet_intended_uses_attributes_0_attestations' }

  it 'lists the attestations, the first one opened, and offers the catalog' do
    expect(rendered).to have_css('.att-d', count: 1)
    expect(rendered).to have_css('button.fr-accordion__btn[aria-expanded="true"]', text: 'Permis de conduire mobile')
    expect(rendered).to have_css("button##{add_button_id}[aria-controls='wallet-catalog-#{use.id}'][data-fr-opened='false']", text: 'Ajouter une attestation')
  end

  context 'when the applicant comes back from the catalog with a new attestation' do
    let(:focus_key) { "attestation_#{pid.id}" }

    before { use.add_attestation(pid) }

    it 'opens and focuses that attestation' do
      expect(rendered).to have_css('button.fr-accordion__btn[aria-expanded="true"][autofocus]', text: 'Données d’identification personnelle (PID)')
      expect(rendered).to have_css('button.fr-accordion__btn[aria-expanded="false"]', text: 'Permis de conduire mobile')
    end
  end

  context 'without any attestation, after « Suivant »' do
    before do
      use.requested_attestations.each(&:mark_for_destruction)
      use.validate
    end

    it 'says that no attestation is requested, and links the error to the add button' do
      expect(rendered).to have_text('Aucune attestation')
      expect(rendered).to have_css("##{add_button_id}-messages .fr-message--error")
      expect(rendered).to have_css("button##{add_button_id}[aria-describedby='#{add_button_id}-messages']")
    end
  end

  context 'when the add button has the focus' do
    let(:focus_key) { 'add_attestation' }

    it 'focuses it' do
      expect(rendered).to have_css("button##{add_button_id}[autofocus]")
    end
  end
end
