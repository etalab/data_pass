RSpec.describe Molecules::PublicRegistry::DownloadCalloutComponent, type: :component do
  subject(:page_content) { render_inline(described_class.new) }

  it 'explains the open data publication and links to the data set' do
    expect(page_content).to have_css('h2.fr-h6', text: 'Télécharger le registre')
    expect(page_content).to have_css('p.fr-text--sm', text: /article L114-8 du code des relations entre le public et l’administration\. Le fichier est mis à jour le 1er de chaque mois\.\z/)
    expect(page_content).to have_link('Habilitations DataPass validées, sur data.gouv.fr', href: Atoms::PublicRegistry::DatasetLinkComponent::DATASET_URL)
  end
end
