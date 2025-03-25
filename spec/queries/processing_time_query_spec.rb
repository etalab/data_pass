RSpec.describe ProcessingTimeQuery, type: :query do
  describe '#perform' do
    subject(:average_days) { described_class.new(authorization_request_class).perform }

    let(:authorization_request_class) { nil }

    before do
      api_entreprise_request = create(:authorization_request, :api_entreprise)
      api_particulier_request = create(:authorization_request, :api_particulier)

      api_entreprise_changelog = create(:authorization_request_changelog, authorization_request: api_entreprise_request)
      api_particulier_changelog = create(:authorization_request_changelog, authorization_request: api_particulier_request)

      api_entreprise_authorization = create(:authorization, request: api_entreprise_request)
      api_particulier_authorization = create(:authorization, request: api_particulier_request)

      create(:authorization_request_event,
        name: 'submit',
        entity: api_entreprise_changelog,
        created_at: 30.days.ago,
        user: api_entreprise_request.applicant)

      create(:authorization_request_event,
        name: 'submit',
        entity: api_particulier_changelog,
        created_at: 20.days.ago,
        user: api_particulier_request.applicant)

      create(:authorization_request_event,
        name: 'approve',
        entity: api_entreprise_authorization,
        created_at: 20.days.ago,
        user: api_entreprise_request.applicant)

      create(:authorization_request_event,
        name: 'approve',
        entity: api_particulier_authorization,
        created_at: 5.days.ago,
        user: api_particulier_request.applicant)
    end

    it 'returns an integer' do
      expect(average_days).to be_an(Integer)
    end

    it 'calculates the average processing time between submit and decision events' do
      expect(average_days).to eq(13)
    end

    context 'when there are no authorization requests' do
      before do
        AuthorizationRequestEvent.delete_all
      end

      it 'returns 0' do
        expect(average_days).to eq(0)
      end
    end

    context 'when filtering by authorization request class' do
      let(:authorization_request_class) { 'AuthorizationRequest::APIEntreprise' }

      it 'only includes the processing time for the specified class' do
        expect(average_days).to eq(10)
      end
    end
  end
end
