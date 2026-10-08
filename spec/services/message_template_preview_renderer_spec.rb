RSpec.describe MessageTemplatePreviewRenderer do
  subject(:renderer) { described_class.new(message_template, entity_name:) }

  let(:entity_name) { 'Jean Dupont' }

  describe '#render' do
    subject(:render) { renderer.render }

    context 'with refusal template' do
      let(:message_template) { create(:message_template, template_type: :refusal) }

      it 'renders the refuse mailer template' do
        expect(render).to include('a été refusée')
      end

      it 'includes the entity name' do
        expect(render).to include('Jean')
      end
    end

    context 'with modification_request template' do
      let(:message_template) { create(:message_template, template_type: :modification_request) }

      it 'renders the request_changes mailer template' do
        expect(render).to include('requiert des modifications')
      end
    end

    context 'with approval template' do
      let(:message_template) { create(:message_template, template_type: :approval, content: 'Message complémentaire de test') }

      it 'renders the approve mailer template' do
        expect(render).to include('a été validée')
      end

      it 'includes the complementary message from latest_authorization' do
        expect(render).to include('Message complémentaire de test')
      end
    end

    # rubocop:disable-next Style/FormatStringToken
    context 'with content containing interpolation variables' do
      let(:message_template) { create(:message_template, content: 'Voir demande %{demande_id}') }

      it 'interpolates the variables' do
        expect(render).to include("Voir demande #{described_class::PREVIEW_REQUEST_ID}")
      end
    end

    context 'with an authorization request class without intitule' do
      let(:message_template) { build(:message_template, authorization_definition_uid: 'formulaire_qf', template_type: :refusal) }

      it 'renders the refuse mailer template' do
        expect(render).to include('a été refusée')
      end
    end

    context 'with a definition specific approval template reading the organization' do
      let(:message_template) { build(:message_template, authorization_definition_uid: 'hubee_dila', template_type: :approval) }

      it 'renders the organization name' do
        expect(render).to include(described_class::PREVIEW_ORGANIZATION_NAME)
      end
    end

    context 'with a dynamic authorization definition' do
      let!(:habilitation_type) { create(:habilitation_type) }
      let(:message_template) { build(:message_template, authorization_definition_uid: habilitation_type.uid, template_type: :refusal) }

      before do
        AuthorizationDefinition.reset!
        AuthorizationRequestForm.reset!
      end

      after do
        AuthorizationDefinition.reset!
        AuthorizationRequestForm.reset!
      end

      it 'renders the refuse mailer template' do
        expect(render).to include('a été refusée')
      end
    end

    describe 'every static authorization definition with message templates' do
      AuthorizationDefinition.yaml_records.select { |definition| definition.feature?(:message_templates) }.each do |definition|
        MessageTemplate.template_types.each_key do |template_type|
          it "renders the #{template_type} preview for #{definition.id}" do
            message_template = build(:message_template, authorization_definition_uid: definition.id, template_type:)

            expect { described_class.new(message_template, entity_name:).render }.not_to raise_error
          end
        end
      end
    end
  end
end
