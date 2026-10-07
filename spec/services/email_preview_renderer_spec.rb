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

    context 'with an authorization request embedding the CNOUS extraction block' do
      let(:habilitation_type) do
        create(:habilitation_type,
          contact_types: ['contact_metier'],
          blocks: [{ 'name' => 'basic_infos' }, { 'name' => 'cnous_data_extraction_criteria' }, { 'name' => 'contacts' }])
      end
      let(:authorization_request) do
        create(:authorization_request, type: habilitation_type.authorization_request_type, form_uid: habilitation_type.slug)
      end
      let(:hubee_file_retention_notice) { 'le fichier sera automatiquement supprimé de HubEE' }

      before do
        AuthorizationDefinition.reset!
        AuthorizationRequestForm.reset!
      end

      after do
        AuthorizationDefinition.reset!
        AuthorizationRequestForm.reset!
      end

      context 'with approval action' do
        let(:action) { :approval }

        it 'shows the instructor the HubEE file retention notice sent to the applicant' do
          expect(render).to include(hubee_file_retention_notice)
        end
      end

      context 'with refusal action' do
        let(:action) { :refusal }

        it 'does not include the HubEE file retention notice' do
          expect(render).not_to include(hubee_file_retention_notice)
        end
      end
    end
  end
end
