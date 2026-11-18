RSpec.describe Atoms::PublicRegistry::DatasetLinkComponent, type: :component do
  subject(:page_content) { render_inline(described_class.new) }

  it 'links to the data.gouv.fr data set in a new window' do
    expect(page_content).to have_css(
      'a.fr-link.fr-link--sm[href="https://www.data.gouv.fr/datasets/habilitations-datapass-validees"][target="_blank"][rel="noopener"]',
      text: 'Habilitations DataPass validées, sur data.gouv.fr'
    )
  end

  it 'announces the new window once, in the link text for screen readers' do
    expect(page_content).to have_css('a span.fr-sr-only', text: '- nouvelle fenêtre')
    expect(page_content).to have_link(exact_text: 'Habilitations DataPass validées, sur data.gouv.fr - nouvelle fenêtre')
    expect(page_content).to have_no_css('a[title]')
  end

  context 'when the credentials set another data set slug' do
    before do
      allow(DatagouvAPIClient).to receive(:dataset_slug).and_return('autre-jeu')
    end

    it 'links to the data set read by the data.gouv.fr client' do
      expect(page_content).to have_link(href: 'https://www.data.gouv.fr/datasets/autre-jeu')
    end
  end
end
