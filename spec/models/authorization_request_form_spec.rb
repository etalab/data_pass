RSpec.describe AuthorizationRequestForm do
  describe '.all' do
    it 'returns a list of all authorizations forms' do
      expect(described_class.all).to be_all { |a| a.is_a? AuthorizationRequestForm }
    end

    context 'with DB records' do
      before do
        stub_const('AuthorizationRequest::MonAPI', Class.new(AuthorizationRequest))
        allow(described_class).to receive(:db_records).and_return([db_form])
        described_class.reset!
      end

      after { described_class.reset! }

      let(:db_form) do
        described_class.new(
          uid: 'mon-api',
          default: true,
          introduction: 'Mon introduction',
          authorization_request_class: AuthorizationRequest::MonAPI,
          steps: [{ name: 'basic_infos' }],
          static_blocks: [],
          service_provider: nil,
          use_case: nil,
          single_page_view: nil,
          scopes_config: {},
        )
      end

      it 'includes YAML forms' do
        expect(described_class.all.map(&:uid)).to include('api-entreprise')
      end

      it 'includes DB forms' do
        expect(described_class.all.map(&:uid)).to include('mon-api')
      end

      it 'returns AuthorizationRequestForm instances for DB records' do
        expect(described_class.all.find { |f| f.uid == 'mon-api' }).to be_a(described_class)
      end

      it 'has default: true for DB forms' do
        form = described_class.all.find { |f| f.uid == 'mon-api' }
        expect(form.default).to be(true)
      end

      it 'has the correct authorization_request_class' do
        form = described_class.all.find { |f| f.uid == 'mon-api' }
        expect(form.authorization_request_class).to eq(AuthorizationRequest::MonAPI)
      end
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
