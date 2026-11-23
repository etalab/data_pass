RSpec.describe Organisms::WalletRegistry::CatalogModalComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new(authorization_request:, use:)) }

  let(:authorization_request) { create(:authorization_request, :registre_wallet, fill_all_attributes: true) }
  let(:use) { authorization_request.wallet_intended_uses.first }
  let(:catalog_path) { "/formulaires/registre-wallet/demande/#{authorization_request.id}/utilisations-prevues/#{use.id}/attestations" }

  it 'opens as a dialog named after its title, for the use' do
    expect(rendered).to have_css("dialog#wallet-catalog-#{use.id}[role='dialog'][aria-labelledby='wallet-catalog-#{use.id}-title']")
    expect(rendered).to have_css("[data-controller='wallet-catalog'][data-wallet-catalog-url-value='#{catalog_path}']")
    expect(rendered).to have_text('Vérifier la majorité')
  end

  it 'loads the results lazily, and offers the full page without JavaScript' do
    expect(rendered).to have_css("turbo-frame#wallet-catalog-#{use.id}-results[src='#{catalog_path}'][loading='lazy']")
    expect(rendered).to have_css("button[name='wallet_command'][value='open_catalog:#{use.id}']")
  end

  it 'tells where to ask for a missing attestation' do
    expect(rendered).to have_button('Mon attestation n’est pas dans la liste')
    expect(rendered).to have_link('l’équipe du registre', visible: :all, href: "mailto:#{authorization_request.definition.support_email}")
  end
end
