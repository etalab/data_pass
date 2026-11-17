RSpec.describe Organisms::PublicRegistry::ResultsListComponent, type: :component do
  def entry(number)
    Molecules::PublicRegistry::AuthorizationEntry.new(denomination: 'Ville de Clamart', service: 'APIParticulier', provider: 'DINUM', validated_on: Date.new(2026, 7, 2), number:)
  end

  it 'renders one full width list item per tile in an unstyled DSFR grid' do
    page_content = render_inline(described_class.new) do |list|
      list.with_tile(url: '#', entry: entry('H44120'))
      list.with_tile(url: '#', entry: entry('H44121'))
    end

    expect(page_content).to have_css('ul.fr-grid-row.fr-grid-row--gutters.fr-raw-list > li.fr-col-12 > div.fr-tile', count: 2)
  end

  it 'renders nothing without tiles' do
    expect(render_inline(described_class.new).to_html).to be_empty
  end
end
