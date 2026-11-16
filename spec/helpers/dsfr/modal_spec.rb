RSpec.describe Dsfr::Modal do
  describe '#dsfr_main_modal_button' do
    subject(:button) { Capybara.string(helper.dsfr_main_modal_button('3 API activées', '/droits', **options)).find('a') }

    context 'without options' do
      let(:options) { {} }

      it 'controls the main modal through its turbo frame' do
        expect(button['aria-controls']).to eq('main-modal')
        expect(button['data-turbo-frame']).to eq('main-modal-content')
        expect(button['id']).to eq('main-modal_button')
      end
    end

    context 'with an accessible label and an id' do
      let(:options) { { id: 'droits-user-1', aria: { label: 'Voir le détail des droits de a@b.fr' } } }

      it 'keeps them alongside the modal wiring' do
        expect(button['aria-label']).to eq('Voir le détail des droits de a@b.fr')
        expect(button['aria-controls']).to eq('main-modal')
        expect(button['id']).to eq('droits-user-1')
      end
    end
  end
end
