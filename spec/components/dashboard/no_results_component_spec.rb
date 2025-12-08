RSpec.describe Dashboard::NoResultsComponent, type: :component do
  before do
    I18n.backend.store_translations(:fr, {
      dashboard: {
        show: {
          no_results: {
            message: 'Aucun résultat pour ce filtre',
            suggestion: 'Essayez de modifier vos critères de recherche'
          }
        }
      }
    })
  end

  describe 'rendering' do
    it 'displays the no results message' do
      component = render_inline(described_class.new)

      expect(component).to have_text('Aucun résultat pour ce filtre')
    end

    it 'displays the suggestion' do
      component = render_inline(described_class.new)

      expect(component).to have_text('Essayez de modifier vos critères de recherche')
    end

    it 'uses DSFR callout styling' do
      component = render_inline(described_class.new)

      expect(component).to have_css('div.fr-callout')
      expect(component).to have_css('p.fr-callout__text')
    end
  end
end
