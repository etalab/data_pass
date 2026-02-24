RSpec.describe Stats::BaseStatsQuery, type: :query do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:date_range) { Date.new(2025, 1, 1)..Date.new(2025, 12, 31) }

  before do
    user.add_to_organization(organization, current: true)
  end

  describe 'filtering by date range through events' do
    let!(:request_with_submit_in_range) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Date.new(2025, 6, 1))
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Date.new(2025, 6, 2))
      end
    end

    let!(:request_with_submit_outside_range) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Date.new(2024, 6, 1))
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Date.new(2024, 6, 2))
      end
    end

    it 'counts submit events within the date range regardless of creation date' do
      query = Stats::VolumeStatsQuery.new(date_range: date_range)

      expect(query.total_requests_submitted_count).to eq(1)
    end

    it 'counts events from requests created before the range if events fall within range' do
      create(:authorization_request_event, :submit,
        authorization_request: request_with_submit_outside_range,
        user: user,
        created_at: Date.new(2025, 3, 1))

      query = Stats::VolumeStatsQuery.new(date_range: date_range)

      expect(query.total_requests_submitted_count).to eq(2)
    end
  end

  describe 'filtering by providers' do
    let!(:api_entreprise_request) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Date.new(2025, 6, 1))
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Date.new(2025, 6, 2))
      end
    end

    it 'accepts providers parameter' do
      query = Stats::VolumeStatsQuery.new(date_range: date_range, providers: ['dinum'])

      expect(query.providers).to eq(['dinum'])
    end
  end

  describe 'filtering by authorization types' do
    let!(:api_entreprise_request) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Date.new(2025, 6, 1))
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Date.new(2025, 6, 2))
      end
    end

    let!(:api_particulier_request) do
      create(:authorization_request, :api_particulier, applicant: user, organization: organization).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Date.new(2025, 6, 1))
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Date.new(2025, 6, 2))
      end
    end

    it 'only counts requests matching the authorization type' do
      query = Stats::VolumeStatsQuery.new(
        date_range: date_range,
        authorization_types: ['AuthorizationRequest::APIEntreprise']
      )

      expect(query.total_requests_submitted_count).to eq(1)
    end
  end

  describe 'filtering by forms' do
    let!(:request_with_api_entreprise_form) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Date.new(2025, 6, 1))
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Date.new(2025, 6, 2))
      end
    end

    let!(:request_with_api_particulier_form) do
      create(:authorization_request, :api_particulier, applicant: user, organization: organization).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Date.new(2025, 6, 1))
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Date.new(2025, 6, 2))
      end
    end

    it 'only counts requests matching the form UID' do
      query = Stats::VolumeStatsQuery.new(
        date_range: date_range,
        forms: ['api-entreprise']
      )

      expect(query.total_requests_submitted_count).to eq(1)
    end
  end
end
