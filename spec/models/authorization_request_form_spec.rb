RSpec.describe AuthorizationRequestForm do
  describe '.all' do
    it 'returns a list of all authorizations forms' do
      expect(described_class.all).to be_all { |a| a.is_a? AuthorizationRequestForm }
    end

    context 'with DB records' do
      let!(:habilitation_type) { create(:habilitation_type, name: 'Mon API') }
      let(:default_template) { habilitation_type.form_templates.find_by(default: true) }

      before { described_class.reset! }

      after { described_class.reset! }

      it 'includes YAML forms' do
        expect(described_class.all.map(&:uid)).to include('api-entreprise')
      end

      it 'includes the auto-created default FormTemplate' do
        expect(described_class.all.map(&:uid)).to include(default_template.slug)
      end

      it 'returns AuthorizationRequestForm instances for DB records' do
        expect(described_class.all.find { |f| f.uid == default_template.slug }).to be_a(described_class)
      end

      it 'reflects FormTemplate.default on the ARF' do
        form = described_class.all.find { |f| f.uid == default_template.slug }
        expect(form.default).to be(true)
      end

      it 'binds the correct authorization_request_class via the habilitation_type' do
        form = described_class.all.find { |f| f.uid == default_template.slug }
        expected_class = AuthorizationRequest.const_get(habilitation_type.uid.classify)
        expect(form.authorization_request_class).to eq(expected_class)
      end

      it 'exposes N templates as N forms for a single habilitation_type' do
        habilitation_type.form_templates.create!(name: 'Second cas', default: false)
        habilitation_type.form_templates.create!(name: 'Troisième cas', default: false)
        described_class.reset!

        forms = described_class.all.select { |f| f.authorization_request_class.to_s == habilitation_type.authorization_request_type }
        expect(forms.size).to eq(3)
        expect(forms.count(&:default)).to eq(1)
      end

      context 'when FormTemplate fields are blank (cascade from HabilitationType)' do
        it 'cascades name from HT.name' do
          form = described_class.all.find { |f| f.uid == default_template.slug }

          expect(default_template.name).to be_blank
          expect(form.name).to eq(habilitation_type.name)
        end

        it 'cascades introduction from HT.form_introduction' do
          habilitation_type.update!(form_introduction: 'Bienvenue v1')
          described_class.reset!

          form = described_class.all.find { |f| f.uid == default_template.slug }
          expect(form.introduction).to eq('Bienvenue v1')
        end

        it 'cascades steps from HT.ordered_steps when template.steps is empty' do
          habilitation_type.update!(blocks: [{ 'name' => 'basic_infos' }, { 'name' => 'legal' }])
          described_class.reset!

          form = described_class.all.find { |f| f.uid == default_template.slug }
          expect(form.steps).to eq([{ name: 'basic_infos' }, { name: 'legal' }])
        end

        it 'lets a non-blank template override take precedence over HT' do
          habilitation_type.update!(form_introduction: 'Hérité du HT')
          default_template.update!(introduction: 'Override template')
          described_class.reset!

          form = described_class.all.find { |f| f.uid == default_template.slug }
          expect(form.introduction).to eq('Override template')
        end
      end

      it 'resolves the service_provider from FormTemplate.service_provider_id' do
        sp_id = ServiceProvider.all.first.id
        default_template.update!(service_provider_id: sp_id)
        described_class.reset!

        form = described_class.all.find { |f| f.uid == default_template.slug }
        expect(form.service_provider).to eq(ServiceProvider.find(sp_id))
      end

      it 'deep-symbolizes all jsonb overrides consumed by views' do
        default_template.update!(
          steps: [{ 'name' => 'basic_infos', 'options' => { 'optional' => true } }],
          static_blocks: [{ 'name' => 'specific_requirements' }],
          scopes_config: { 'hide' => ['scope_a'] },
          initialize_with: { 'scopes' => ['scope_b'] },
        )
        described_class.reset!

        form = described_class.all.find { |f| f.uid == default_template.slug }
        expect(form.steps).to eq([{ name: 'basic_infos', options: { optional: true } }])
        expect(form.static_blocks).to eq([{ name: 'specific_requirements' }])
        expect(form.scopes_config).to eq(hide: ['scope_a'])
        expect(form.initialize_with[:scopes]).to include('scope_b')
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
