require 'rails_helper'

RSpec.describe Atoms::PictogramComponent, type: :component do
  subject(:rendered) { render_inline(component) }

  let(:component) { described_class.new(name: 'digital/search') }

  it 'renders a decorative svg with the three pictogram layers' do
    expect(rendered).to have_css('svg.fr-artwork[aria-hidden="true"][width="80"][height="80"]')
    expect(rendered).to have_css('use.fr-artwork-decorative[href*="artwork/pictograms/digital/search"][href$="#artwork-decorative"]')
    expect(rendered).to have_css('use.fr-artwork-minor')
    expect(rendered).to have_css('use.fr-artwork-major')
  end

  context 'with a custom size' do
    let(:component) { described_class.new(name: 'digital/search', size: 56) }

    it 'applies the size' do
      expect(rendered).to have_css('svg[width="56"][height="56"]')
    end
  end

  context 'with the ovoid background' do
    let(:component) { described_class.new(name: 'system/technical-error', background: :ovoid) }

    it 'renders the background layers and the pictogram' do
      expect(rendered).to have_css('svg.fr-responsive-img.fr-artwork[width="160"][height="200"]')
      expect(rendered).to have_css('use.fr-artwork-motif[href*="artwork/background/ovoid"]')
      expect(rendered).to have_css('g use.fr-artwork-major[href*="system/technical-error"]')
    end
  end

  context 'with an unknown background' do
    it 'raises ArgumentError' do
      expect {
        described_class.new(name: 'digital/search', background: :carre)
      }.to raise_error(ArgumentError, /background must be one of/)
    end
  end
end
