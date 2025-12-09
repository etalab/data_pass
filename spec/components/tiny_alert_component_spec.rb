RSpec.describe TinyAlertComponent, type: :component do
  let(:message) { 'Demande sauvegardée' }
  let(:type) { :success }
  let(:dismissible) { true }
  let(:component) { described_class.new(type:, message:, dismissible:) }

  describe 'rendering' do
    before { render_inline(component) }

    it 'renders the message' do
      expect(page).to have_content(message)
    end

    it 'renders the alert with correct type class' do
      expect(page).to have_css('.fr-alert.fr-alert--success.fr-alert--sm')
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

    context 'when type is error' do
      let(:type) { :error }

      it 'renders error alert' do
        expect(page).to have_css('.fr-alert.fr-alert--error')
      end
    end

    context 'when dismissible' do
      let(:dismissible) { true }

      it 'renders close button' do
        expect(page).to have_button('Masquer le message')
      end
    end

    context 'when not dismissible' do
      let(:dismissible) { false }

      it 'does not render close button' do
        expect(page).to have_no_button('Masquer le message')
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
