RSpec.describe Organisms::WalletRegistry::AttestationComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new(use:, index: 0, attestation:, open:, focused:)) }

  let(:authorization_request) { create(:authorization_request, :registre_wallet, fill_all_attributes: true) }
  let(:use) { authorization_request.wallet_intended_uses.first }
  let(:attestation) { use.attestations.first }
  let(:open) { true }
  let(:focused) { false }
  let(:age_over_18) { attestation.rulebook.claims.find_by!(identifier: 'age_over_18') }

  it 'counts the checked data in the accordion title, and checks them' do
    expect(rendered).to have_css('button.fr-accordion__btn[aria-expanded="true"]', text: 'Permis de conduire mobile · 1 donnée demandée')
    expect(rendered).to have_checked_field(id: "authorization_request_registre_wallet_wallet_intended_uses_attributes_0_claim_#{attestation.rulebook_id}_age_over_18")
    expect(rendered).to have_css("input[type='checkbox'][value='#{age_over_18.id}'][name='authorization_request_registre_wallet[wallet_intended_uses_attributes][0][requested_attestations_attributes][0][selected_claim_ids][]']")
  end

  it 'flags a provisional attestation and opens the documentation in a new window' do
    expect(rendered).to have_css('.fr-badge--warning', text: 'Liste provisoire')
    expect(rendered).to have_css('a[target="_blank"] .fr-sr-only', text: 'nouvelle fenêtre')
  end

  it 'asks a confirmation before removing the attestation' do
    expect(rendered).to have_css("button[aria-controls='wallet-remove-attestation-#{use.id}-#{attestation.rulebook_id}']", text: 'Retirer cette attestation')
    expect(rendered).to have_css("dialog#wallet-remove-attestation-#{use.id}-#{attestation.rulebook_id}")
  end

  context 'when closed and focused' do
    let(:open) { false }
    let(:focused) { true }

    it 'collapses the data and focuses the accordion button' do
      expect(rendered).to have_css('button.fr-accordion__btn[aria-expanded="false"][autofocus]')
      expect(rendered).to have_no_css('.fr-collapse--expanded')
    end
  end

  context 'when no data is checked after « Suivant »' do
    before do
      attestation.selected_claim_ids = []
      use.validate
    end

    it 'shows the error and links it to the accordion button' do
      message_id = "authorization_request_registre_wallet_wallet_intended_uses_attributes_0_attestation_#{attestation.rulebook_id}-messages"

      expect(rendered).to have_css("##{message_id} .fr-message--error")
      expect(rendered).to have_css("button.fr-accordion__btn[aria-describedby='#{message_id}']")
    end
  end
end
