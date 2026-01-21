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

    # rubocop:disable Style/FormatStringToken
    context 'with content containing interpolation variables' do
      let(:message_template) { create(:message_template, content: 'Voir demande %{demande_id}') }

      it 'interpolates the variables' do
        expect(render).to include("Voir demande #{described_class::PREVIEW_REQUEST_ID}")
      end
    end
    # rubocop:enable Style/FormatStringToken
  end
end
