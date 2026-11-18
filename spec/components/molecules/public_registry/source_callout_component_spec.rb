RSpec.describe Molecules::PublicRegistry::SourceCalloutComponent, type: :component do
  subject(:page_content) { render_inline(described_class.new) }

  it 'renders the source text on a grey background' do
    expect(page_content).to have_css('div.fr-background-alt--grey.fr-p-3w h2.fr-h5', text: 'Source')
    expect(page_content).to have_css('p.fr-text--sm', text: 'Ces informations sont aussi publiées en open data, mises à jour le 1er de chaque mois. DataPass ne publie ni les contacts, ni les pièces jointes, ni les échanges de l’instruction.')
  end

  it 'links to the open data set' do
    expect(page_content).to have_link('Habilitations DataPass validées, sur data.gouv.fr', href: 'https://www.data.gouv.fr/datasets/habilitations-datapass-validees')
  end
end
