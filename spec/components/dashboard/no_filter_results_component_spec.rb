RSpec.describe Dashboard::NoFilterResultsComponent, type: :component do
  before do
    I18n.backend.store_translations(:fr, {
      dashboard: {
        show: {
          no_filter_results: {
            demandes: {
              message: "Nous n'avons pas trouvé de demande avec les filtres que vous avez sélectionné"
            },
            habilitations: {
              message: "Nous n'avons pas trouvé d'habilitation avec les filtres que vous avez sélectionné"
            }
          }
        }
      }
    })
  end

  describe 'rendering for demandes tab' do
    it 'displays the pictogram' do
      component = render_inline(described_class.new(tab_type: 'demandes'))

      expect(component).to have_css('img[alt=""]')
      expect(component.css('img').first['src']).to include('information')
    end

    it 'displays the no results message for demandes' do
      component = render_inline(described_class.new(tab_type: 'demandes'))

      expect(component).to have_text("Nous n'avons pas trouvé de demande avec les filtres que vous avez sélectionné")
    end

    it 'displays a reset filters button' do
      component = render_inline(described_class.new(tab_type: 'demandes'))

      expect(component).to have_button('Réinitialiser les filtres')
      expect(component).to have_css('button.fr-btn.fr-btn--secondary')
    end
  end

  describe 'rendering for habilitations tab' do
    it 'displays the no results message for habilitations' do
      component = render_inline(described_class.new(tab_type: 'habilitations'))

      expect(component).to have_text("Nous n'avons pas trouvé d'habilitation avec les filtres que vous avez sélectionné")
    end
  end
end
