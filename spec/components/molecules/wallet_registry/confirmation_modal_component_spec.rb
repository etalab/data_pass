RSpec.describe Molecules::WalletRegistry::ConfirmationModalComponent, type: :component do
  let(:authorization_request) { create(:authorization_request, :registre_wallet, fill_all_attributes: true) }
  let(:use) { authorization_request.wallet_intended_uses.first }
  let(:attestation) { use.attestations.first }

  describe '.delete_use' do
    subject(:rendered) { render_inline(described_class.delete_use(authorization_request:, use:)) }

    it 'asks to confirm with an alert dialog named after the use' do
      expect(rendered).to have_css("dialog#wallet-delete-use-#{use.id}[role='alertdialog'][aria-labelledby='wallet-delete-use-#{use.id}-title']")
      expect(rendered).to have_css("h1#wallet-delete-use-#{use.id}-title", text: 'Supprimer l’utilisation prévue « Vérifier la majorité » ?')
    end

    it 'sends the command of the step, and lets the applicant cancel' do
      expect(rendered).to have_css("button[type='submit'][name='wallet_command'][value='remove_use:#{use.id}'][formnovalidate]", text: 'Supprimer l’utilisation')
      expect(rendered).to have_css("button[type='button'][aria-controls='wallet-delete-use-#{use.id}']", text: 'Annuler')
    end
  end

  describe '.remove_attestation' do
    subject(:rendered) { render_inline(described_class.remove_attestation(authorization_request:, use:, attestation:, claim_count: 1)) }

    it 'names the attestation and the use, and counts the data that will be removed' do
      expect(rendered).to have_css('h1', text: 'Retirer l’attestation « Permis de conduire mobile » ?')
      expect(rendered).to have_text('La donnée cochée dans cette attestation sera aussi retirée de l’utilisation « Vérifier la majorité ».')
      expect(rendered).to have_css("button[value='remove_attestation:#{use.id}:#{attestation.rulebook_id}']")
    end
  end
end
