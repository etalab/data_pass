RSpec.describe Dashboard::NoFilterResultsComponent, type: :component do
  describe 'rendering for demandes tab' do
    it 'displays the pictogram' do
      component = render_inline(described_class.new(tab_type: 'demandes'))

      expect(component).to have_css('img[alt=""]')
      expect(component.css('img').first['src']).to include('information')
    end

    it 'displays the no results message for demandes' do
      component = render_inline(described_class.new(tab_type: 'demandes'))

      expect(component).to have_text('Nous n’avons pas trouvé de demande avec les filtres que vous avez sélectionné', normalize_ws: true)
    end

    it 'displays a reset filters button' do
      component = render_inline(described_class.new(tab_type: 'demandes'))

      expect(component).to have_link('Réinitialiser les filtres', href: '/tableau-de-bord/demandes')
      expect(component).to have_css('a.fr-btn.fr-btn--secondary')
    end
  end

  describe 'rendering for habilitations tab' do
    it 'displays the no results message for habilitations' do
      component = render_inline(described_class.new(tab_type: 'habilitations'))

      expect(component).to have_text("Nous n’avons pas trouvé d’habilitation avec les filtres que vous avez sélectionné", normalize_ws: true)
    end
  end
end
