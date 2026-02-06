RSpec.describe Stats::BaseStatsQuery, type: :query do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }

  before do
    user.add_to_organization(organization, current: true)
  end

  describe '#filtered_requests' do
    let(:date_range) { Date.new(2025, 1, 1)..Date.new(2025, 12, 31) }

    let!(:request_in_range) do
      create(:authorization_request, :api_entreprise,
        applicant: user,
        organization: organization,
        created_at: Date.new(2025, 6, 1))
    end

    let!(:request_outside_range) do
      create(:authorization_request, :api_entreprise,
        applicant: user,
        organization: organization,
        created_at: Date.new(2024, 6, 1))
    end

    it 'filters requests by date range' do
      query = described_class.new(date_range: date_range)
      requests = query.send(:filtered_requests)

      expect(requests.to_a).to include(request_in_range)
      expect(requests.to_a).not_to include(request_outside_range)
    end

    context 'with providers filter' do
      it 'accepts providers parameter' do
        query = described_class.new(
          date_range: date_range,
          providers: ['dinum']
        )

        expect(query.providers).to eq(['dinum'])
      end
    end

    context 'with authorization_types filter' do
      let!(:api_entreprise_request) do
        create(:authorization_request, :api_entreprise,
          applicant: user,
          organization: organization,
          created_at: Date.new(2025, 6, 1))
      end

      let!(:api_particulier_request) do
        create(:authorization_request, :api_particulier,
          applicant: user,
          organization: organization,
          created_at: Date.new(2025, 6, 1))
      end

      it 'filters by authorization types' do
        query = described_class.new(
          date_range: date_range,
          authorization_types: ['AuthorizationRequest::APIEntreprise']
        )
        requests = query.send(:filtered_requests)

        expect(requests.to_a).to include(api_entreprise_request)
        expect(requests.to_a).not_to include(api_particulier_request)
      end
    end

    context 'with forms filter' do
      let!(:request_with_api_entreprise_form) do
        create(:authorization_request, :api_entreprise,
          applicant: user,
          organization: organization,
          created_at: Date.new(2025, 6, 1))
      end

      let!(:request_with_api_particulier_form) do
        create(:authorization_request, :api_particulier,
          applicant: user,
          organization: organization,
          created_at: Date.new(2025, 6, 1))
      end

      it 'filters by form UIDs' do
        query = described_class.new(
          date_range: date_range,
          forms: ['api-entreprise']
        )
        requests = query.send(:filtered_requests)

        expect(requests.to_a).to include(request_with_api_entreprise_form)
        expect(requests.to_a).not_to include(request_with_api_particulier_form)
      end
    end
  end
end
