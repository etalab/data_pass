RSpec.describe Atoms::PublicRegistry::EntriesCountComponent, type: :component do
  it 'announces the number of entries in the registry without query' do
    page_content = render_inline(described_class.new(count: 31_751))

    expect(page_content).to have_css('p strong', text: /\A31\s751 entrées\z/)
    expect(page_content).to have_css('p', text: /entrées au registre\z/)
  end

  it 'repeats the query' do
    page_content = render_inline(described_class.new(count: 1, query: 'clamart'))

    expect(page_content).to have_css('p', exact_text: '1 entrée pour « clamart »')
  end

  it 'uses the singular when there is no entry' do
    page_content = render_inline(described_class.new(count: 0, query: 'portefeuille'))

    expect(page_content).to have_css('p', exact_text: '0 entrée pour « portefeuille »')
  end

  it 'escapes the query' do
    page_content = render_inline(described_class.new(count: 0, query: '<b>clamart</b>'))

    expect(page_content).to have_no_css('b')
    expect(page_content).to have_text('<b>clamart</b>')
  end

  it 'does not announce itself as a live region' do
    expect(render_inline(described_class.new(count: 3))).to have_no_css('[aria-live]')
  end
end
