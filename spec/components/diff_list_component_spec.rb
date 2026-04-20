RSpec.describe DiffListComponent, type: :component do
  describe '#call' do
    context 'with entries' do
      let(:entries) { ['Le champ X a changé', 'Le champ Y a changé'] }

      it 'renders a list of entries' do
        page = render_inline(described_class.new(entries:))

        expect(page).to have_css('ul')
        expect(page).to have_css('li', count: 2)
        expect(page).to have_text('Le champ X a changé')
        expect(page).to have_text('Le champ Y a changé')
      end
    end

    context 'with empty entries' do
      let(:entries) { [] }

      it 'does not render' do
        page = render_inline(described_class.new(entries:))

        expect(page.text).to be_empty
      end
    end
  end
end
