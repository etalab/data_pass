RSpec.describe Organisms::PublicRegistry::SidebarComponent, type: :component do
  subject(:page_content) { render_inline(described_class.new(url: '/registre-public', origins: ['datapass'], query: 'clamart')) }

  it 'renders a labelled aside shown from 992 px on a grey background' do
    expect(page_content).to have_css('aside.fr-hidden.fr-unhidden-lg.fr-background-alt--grey.fr-p-3w[aria-label="Filtres et téléchargement"]')
  end

  it 'contains the sidebar origin filter with the current selection and the download callout' do
    expect(page_content).to have_css('aside #public-registry-origin-sidebar')
    expect(page_content).to have_css('aside button[aria-pressed="true"]', text: 'Habilitation DataPass')
    expect(page_content).to have_css('aside input[name="q"][value="clamart"]', visible: :hidden)
    expect(page_content).to have_css('aside h2', text: 'Télécharger le registre')
  end
end
