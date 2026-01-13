RSpec.describe EmailPreviewRenderer do
  subject(:renderer) { described_class.new(authorization_request, action:) }

  let(:authorization_request) { create(:authorization_request, :api_entreprise, :submitted) }

  describe '#render' do
    subject(:render) { renderer.render }

    context 'with approval action' do
      let(:action) { :approval }

      it 'renders the approve mailer template' do
        expect(render).to include('a été validée')
      end

      it 'includes the placeholder message' do
        expect(render).to include(described_class::PLACEHOLDER_MESSAGE)
      end
    end

    context 'with refusal action' do
      let(:action) { :refusal }

      it 'renders the refuse mailer template' do
        expect(render).to include('a été refusée')
      end

      it 'includes the placeholder message' do
        expect(render).to include(described_class::PLACEHOLDER_MESSAGE)
      end
    end

    context 'with request_changes action' do
      let(:action) { :request_changes }

      it 'renders the request_changes mailer template' do
        expect(render).to include('requiert des modifications')
      end

      it 'includes the placeholder message' do
        expect(render).to include(described_class::PLACEHOLDER_MESSAGE)
      end
    end

    context 'with reopening authorization request' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :reopened) }
      let(:action) { :approval }

      it 'renders the reopening_approve mailer template' do
        expect(render).to include('réouverture')
      end
    end
  end
end
