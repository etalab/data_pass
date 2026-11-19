RSpec.describe Organisms::PublicRegistry::TwoColumnLayoutComponent, type: :component do
  it 'renders a main column and an aside column on the DSFR grid' do
    page_content = render_inline(described_class.new) do |layout|
      layout.with_main { 'Contenu principal' }
      layout.with_aside { 'Contenu latéral' }
    end

    expect(page_content).to have_css('div.fr-grid-row.fr-grid-row--gutters > div.fr-col-12.fr-col-lg-8', text: 'Contenu principal')
    expect(page_content).to have_css('div.fr-grid-row.fr-grid-row--gutters > div.fr-col-12.fr-col-lg-4', text: 'Contenu latéral')
  end

  it 'renders only the main column without aside' do
    page_content = render_inline(described_class.new) do |layout|
      layout.with_main { 'Contenu principal' }
    end

    expect(page_content).to have_css('div.fr-col-lg-8')
    expect(page_content).to have_no_css('div.fr-col-lg-4')
  end
end
