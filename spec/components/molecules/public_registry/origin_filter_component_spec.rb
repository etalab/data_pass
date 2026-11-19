RSpec.describe Molecules::PublicRegistry::OriginFilterComponent, type: :component do
  subject(:page_content) { render_inline(described_class.new(**params)) }

  let(:params) { { url: '/registre-public', placement: :sidebar } }

  def tag_button(label)
    page_content.at_css("button.fr-tag:contains('#{label}')")
  end

  it 'renders the two origins as selectable submit tags in a labelled group' do
    expect(page_content).to have_css('h2.fr-h6#public-registry-origin-sidebar', text: 'Origine')
    expect(page_content).to have_css('form[method="get"][action="/registre-public"] ul.fr-tags-group[aria-labelledby="public-registry-origin-sidebar"] button.fr-tag.fr-tag--sm[type="submit"][name="origine"]', count: 2)
  end

  context 'without selection' do
    it 'renders both tags unpressed, each submitting its own origin' do
      expect(tag_button('Habilitation DataPass').attributes.slice('aria-pressed', 'value').transform_values(&:value)).to eq('aria-pressed' => 'false', 'value' => 'datapass')
      expect(tag_button('Partie utilisatrice du portefeuille européen')['value']).to eq('portefeuille-europeen')
    end

    it 'has no query field' do
      expect(page_content).to have_no_field('q', type: :hidden, visible: :hidden)
    end
  end

  context 'with DataPass selected and a query' do
    let(:params) { super().merge(origins: ['datapass'], query: 'clamart') }

    it 'marks DataPass as pressed and submits the selection after the click' do
      expect(tag_button('Habilitation DataPass')['aria-pressed']).to eq('true')
      expect(tag_button('Habilitation DataPass')['value'].to_s).to eq('')
      expect(tag_button('Partie utilisatrice du portefeuille européen')['value']).to eq('datapass,portefeuille-europeen')
    end

    it 'keeps the query in a hidden field' do
      expect(page_content).to have_css('input[type="hidden"][name="q"][value="clamart"]', visible: :hidden)
    end
  end

  context 'with only the European wallet selected' do
    let(:params) { super().merge(origins: ['portefeuille-europeen']) }

    it 'submits both origins in a stable order when DataPass is added' do
      expect(tag_button('Habilitation DataPass')['value']).to eq('datapass,portefeuille-europeen')
    end
  end

  context 'with both origins selected' do
    let(:params) { super().merge(origins: %w[portefeuille-europeen datapass]) }

    it 'marks both as pressed and removes each one on click' do
      expect(page_content).to have_css('button[aria-pressed="true"]', count: 2)
      expect(tag_button('Habilitation DataPass')['value']).to eq('portefeuille-europeen')
      expect(tag_button('Partie utilisatrice du portefeuille européen')['value']).to eq('datapass')
    end
  end

  context 'with an unknown origin in the selection' do
    let(:params) { super().merge(origins: %w[wallet datapass]) }

    it 'ignores it' do
      expect(tag_button('Partie utilisatrice du portefeuille européen')['value']).to eq('datapass,portefeuille-europeen')
    end
  end

  context 'with the mobile placement' do
    let(:params) { { url: '/registre-public', placement: :mobile } }

    it 'is hidden from 992 px and titled by a paragraph' do
      expect(page_content).to have_css('div.fr-hidden-lg p.fr-text--bold#public-registry-origin-mobile', text: 'Origine')
      expect(page_content).to have_css('ul.fr-tags-group[aria-labelledby="public-registry-origin-mobile"]')
    end
  end

  it 'rejects an unknown placement' do
    expect { described_class.new(url: '/', placement: :footer) }.to raise_error(ArgumentError, /placement must be one of/)
  end
end
