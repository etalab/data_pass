RSpec.describe Molecules::WalletRegistry::CatalogRulebookComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new(authorization_request:, use:, rulebook:, embedded:)) }

  let(:authorization_request) { create(:authorization_request, :registre_wallet, fill_all_attributes: true) }
  let(:use) { authorization_request.wallet_intended_uses.first }
  let(:rulebook) { WalletRegistry::Rulebook.available.find_by!(identifier: 'pid') }
  let(:embedded) { true }
  let(:command) { "add_attestation:#{use.id}:#{rulebook.id}" }

  it 'describes the attestation and links to its documentation in a new window' do
    expect(rendered).to have_css('h2', text: 'Données d’identification personnelle (PID)')
    expect(rendered).to have_css('a[target="_blank"][rel="noopener"] .fr-sr-only', text: 'nouvelle fenêtre')
  end

  it 'submits the form of the step from the window, out of the frame' do
    expect(rendered).to have_css("button[type='submit'][name='wallet_command'][value='#{command}'][data-turbo-frame='_top']")
    expect(rendered).to have_no_css('form')
  end

  context 'when shown on the full page, without JavaScript' do
    let(:embedded) { false }

    it 'sends its own command' do
      expect(rendered).to have_css("form input[name='wallet_command'][value='#{command}']", visible: :hidden)
      expect(rendered).to have_css('form button', text: 'Ajouter')
    end
  end

  context 'when the use already has the attestation' do
    let(:rulebook) { use.attestations.first.rulebook }

    it 'disables the button' do
      expect(rendered).to have_button(disabled: true, text: 'Déjà ajoutée')
    end
  end
end
