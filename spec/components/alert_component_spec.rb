RSpec.describe AlertComponent, type: :component do
  let(:type) { :error }
  let(:title) { 'Une erreur est survenue' }
  let(:description) { 'Certains champs ne sont pas valides' }
  let(:messages) { [] }
  let(:close_button) { true }
  let(:component) { described_class.new(type:, title:, description:, messages:, close_button:) }

  describe 'rendering' do
    before { render_inline(component) }

    it 'renders the title' do
      expect(page).to have_css('.fr-alert__title', text: title)
    end

    it 'renders the description as paragraph' do
      expect(page).to have_css('p', text: description)
    end

    it 'renders the alert with correct type class' do
      expect(page).to have_css('.fr-alert.fr-alert--error')
    end

    context 'when type is success' do
      let(:type) { :success }

      it 'renders success alert' do
        expect(page).to have_css('.fr-alert.fr-alert--success')
      end
    end

    context 'when type is info' do
      let(:type) { :info }

      it 'renders info alert' do
        expect(page).to have_css('.fr-alert.fr-alert--info')
      end
    end

    context 'when type is warning' do
      let(:type) { :warning }

      it 'renders warning alert' do
        expect(page).to have_css('.fr-alert.fr-alert--warning')
      end
    end

    context 'with close button enabled' do
      let(:close_button) { true }

      it 'renders close button' do
        expect(page).to have_button('Masquer le message')
      end
    end

    context 'with close button disabled' do
      let(:close_button) { false }

      it 'does not render close button' do
        expect(page).to have_no_button('Masquer le message')
      end
    end

    context 'with list of errors' do
      let(:messages) { ['Erreur 1', 'Erreur 2', 'Erreur 3'] }

      it 'renders all errors in a list' do
        expect(page).to have_css('ul li', count: 3)
        expect(page).to have_content('Erreur 1')
        expect(page).to have_content('Erreur 2')
        expect(page).to have_content('Erreur 3')
      end
    end

    context 'with description and messages' do
      let(:description) { 'Une erreur est survenue' }
      let(:messages) { ['Erreur spécifique'] }

      it 'renders description as paragraph and messages as list' do
        expect(page).to have_css('p', text: description)
        expect(page).to have_css('ul li', text: 'Erreur spécifique')
      end
    end

    context 'without description' do
      let(:description) { nil }
      let(:messages) { ['Seule erreur'] }

      it 'renders only the list' do
        expect(page).to have_no_css('p')
        expect(page).to have_css('ul li', text: 'Seule erreur')
      end
    end
  end

  describe 'validation' do
    context 'with invalid type' do
      let(:type) { :invalid }

      it 'raises an error' do
        expect { render_inline(component) }.to raise_error(ArgumentError, /Invalid type/)
      end
    end
  end
end
