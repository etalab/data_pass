RSpec.describe Dsfr::Stepper do
  let(:steps) { ['Mon projet', 'Les données', 'Le cadre juridique'] }

  describe '#dsfr_stepper' do
    subject(:stepper) { helper.dsfr_stepper(current_step:, steps:) }

    context 'when the current step belongs to the steps' do
      let(:current_step) { 'Les données' }

      it 'positions the stepper on that step' do
        expect(stepper).to include('data-fr-current-step="2"')
        expect(stepper).to include('data-fr-steps="3"')
      end

      it 'announces the next step' do
        expect(stepper).to include('Le cadre juridique')
      end
    end

    context 'when the current step is unknown' do
      let(:current_step) { 'Une étape supprimée du formulaire' }

      it 'renders nothing rather than raising' do
        expect(stepper).to eq('')
      end
    end

    context 'when the steps are empty' do
      let(:steps) { [] }
      let(:current_step) { 'Mon projet' }

      it 'renders nothing rather than raising' do
        expect(stepper).to eq('')
      end
    end

    context 'when the current step is the last one' do
      let(:current_step) { 'Le cadre juridique' }

      it 'does not announce a next step' do
        expect(stepper).to include('data-fr-current-step="3"')
        expect(stepper).not_to include('fr-stepper__details')
      end
    end
  end
end
