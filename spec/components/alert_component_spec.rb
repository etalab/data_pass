RSpec.describe AlertComponent, type: :component do
  let(:type) { :error }
  let(:title) { 'Une erreur est survenue' }
  let(:messages) { 'Certains champs ne sont pas valides' }
  let(:close_button) { true }
  let(:component) { described_class.new(type:, title:, messages:, close_button:) }

  describe 'rendering' do
    before { render_inline(component) }

    it 'renders the title' do
      expect(page).to have_css('.fr-alert__title', text: title)
    end

    it 'renders the message with simple_format' do
      expect(page).to have_css('p', text: messages)
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

    context 'with single message as array' do
      let(:messages) { ['Seule erreur'] }

      it 'renders with simple_format not list' do
        expect(page).to have_no_css('ul')
        expect(page).to have_css('p', text: 'Seule erreur')
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
