RSpec.describe AuthorizationRequestForm do
  describe '.all' do
    it 'returns a list of all authorizations forms' do
      expect(described_class.all).to be_all { |a| a.is_a? AuthorizationRequestForm }
    end
  end

  describe '#prefilled?' do
    subject(:prefilled?) { form.prefilled? }

    context 'when the form is prefilled' do
      let(:form) { described_class.find('api-entreprise-mgdis') }

      it { is_expected.to be true }
    end

    context 'when the form is not prefilled' do
      let(:form) { described_class.find('api-entreprise') }

      it { is_expected.to be false }
    end
  end

  describe '#stage' do
    subject(:stage) { form.stage }

    context 'when stage is defined' do
      let(:form) { described_class.find('api-impot-particulier-cantine-scolaire-production') }

      it { is_expected.to be_a AuthorizationRequestForm::Stage }

      it 'has the correct definition' do
        expect(stage.definition).to eq(form.authorization_definition)
      end

      it 'has the correct previous_form_uid' do
        expect(stage.previous_form_uid).to eq('api-impot-particulier-cantine-scolaire-sandbox')
      end
    end

    context 'when stage is not defined' do
      context 'when definition has no multiple stages' do
        let(:form) { described_class.find('api-entreprise') }

        it { is_expected.to be_nil }
      end

      context 'when definition has multiple stages' do
        context 'when definition has previous stages' do
          let(:form) { described_class.find('api-hermes-production') }

          it { is_expected.to be_a AuthorizationRequestForm::Stage }

          it 'has the correct definition' do
            expect(stage.definition).to eq(form.authorization_definition)
          end

          it 'has the correct previous_form_uid' do
            expect(stage.previous_form_uid).to eq('api-hermes-sandbox')
          end
        end

        context 'when definition has no previous stages' do
          let(:form) { described_class.find('api-hermes-sandbox') }

          it { is_expected.to be_a AuthorizationRequestForm::Stage }

          it 'has the correct definition' do
            expect(stage.definition).to eq(form.authorization_definition)
          end

          it 'has no previous_form_uid' do
            expect(stage.previous_form_uid).to be_nil
          end
        end
      end
    end
  end
end
