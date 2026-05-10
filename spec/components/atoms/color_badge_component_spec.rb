require 'rails_helper'

RSpec.describe Atoms::ColorBadgeComponent, type: :component do
  describe '#call' do
    subject(:rendered) { render_inline(component) }

    let(:component) { described_class.new(label: 'Manager', color: 'purple-glycine') }

    it 'renders a paragraph with the label' do
      expect(rendered).to have_css('p', text: 'Manager')
    end

    it 'applies DSFR badge classes with the requested color' do
      expect(rendered).to have_css('p.fr-badge.fr-badge--sm.fr-badge--purple-glycine.fr-badge--no-icon')
    end

    context 'with a custom size' do
      let(:component) { described_class.new(label: 'Manager', color: 'purple-glycine', size: :md) }

      it 'applies the size modifier' do
        expect(rendered).to have_css('p.fr-badge.fr-badge--md')
      end
    end

    context 'with an unknown color' do
      it 'raises ArgumentError' do
        expect {
          described_class.new(label: 'X', color: 'fuchsia-imaginaire')
        }.to raise_error(ArgumentError, /color must be one of/)
      end
    end

    context 'with an unknown size' do
      it 'raises ArgumentError' do
        expect {
          described_class.new(label: 'X', color: 'blue-ecume', size: :xl)
        }.to raise_error(ArgumentError, /size must be one of/)
      end
    end
  end
end
