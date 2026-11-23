RSpec.describe Molecules::WalletRegistry::WalletPreviewComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new(authorization_request:, uses:, previewed_use:)) }

  let(:authorization_request) { create(:authorization_request, :registre_wallet, fill_all_attributes: true) }
  let(:use) { authorization_request.wallet_intended_uses.first }
  let(:uses) { [use] }
  let(:previewed_use) { nil }

  it 'shows what the user will read in the wallet, without a selector for a single use' do
    expect(rendered).to have_css('h3', text: 'Ce que verra l’usager')
    expect(rendered).to have_css('.wallet-preview__value', text: 'Vélocité Libre-service')
    expect(rendered).to have_css('.wallet-preview li', text: 'Plus de 18 ans')
    expect(rendered).to have_text('Vérifier que vous avez plus de 18 ans avant de vous louer un vélo.')
    expect(rendered).to have_no_select('wallet-preview-use')
  end

  context 'without any use' do
    let(:uses) { [] }

    it 'invites to add a use' do
      expect(rendered).to have_text('Ajoutez une utilisation prévue pour voir l’aperçu.')
    end
  end

  context 'with two uses' do
    let(:pid) { WalletRegistry::Rulebook.available.find_by!(identifier: 'pid') }
    let(:account) { authorization_request.wallet_intended_uses.build(id: use.id + 1, name: 'Ouvrir un compte client', start_date: Date.current).tap { |account| account.add_attestation(pid) } }
    let(:uses) { [use, account] }
    let(:previewed_use) { account }

    it 'selects the previewed use in the list, and renders one preview per use' do
      expect(rendered).to have_select('wallet-preview-use', selected: 'Ouvrir un compte client', options: ['Vérifier la majorité', 'Ouvrir un compte client'])
      expect(rendered).to have_css('.wallet-preview[data-use-id]', count: 2)
    end

    it 'says when a use has no data nor purpose yet' do
      expect(rendered).to have_css("[data-use-id='#{account.id}'] .wx-muted", text: 'Aucune donnée')
      expect(rendered).to have_css("[data-use-id='#{account.id}'] em", text: 'Finalité à rédiger')
    end
  end
end
