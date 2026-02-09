RSpec.describe Stats::VolumeStatsQuery, type: :query do
  let(:date_range) { Date.new(2025, 1, 1)..Date.new(2025, 12, 31) }
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }

  before do
    user.add_to_organization(organization, current: true)
  end

  describe '#total_requests_submitted_count' do
    let!(:request_with_multiple_submits) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: Date.new(2025, 5, 1)).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Date.new(2025, 5, 1))
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Date.new(2025, 5, 2))
        create(:authorization_request_event, :reopen, authorization_request: ar, user: user, created_at: Date.new(2025, 6, 1))
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Date.new(2025, 6, 2))
      end
    end

    let!(:request_submitted_outside_range) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: Date.new(2024, 6, 1)).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Date.new(2024, 6, 1))
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Date.new(2024, 6, 2))
      end
    end

    it 'counts all submit events in date range' do
      query = described_class.new(date_range: date_range)
      expect(query.total_requests_submitted_count).to eq(2)
    end
  end

  describe '#new_requests_submitted_count' do
    let!(:request_submitted_in_range) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: Date.new(2025, 6, 1)).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Date.new(2025, 6, 1))
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Date.new(2025, 6, 2))
      end
    end

    let!(:request_submitted_outside_range) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: Date.new(2024, 6, 1)).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Date.new(2024, 6, 1))
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Date.new(2024, 6, 2))
      end
    end

    it 'counts requests with first submit in date range' do
      query = described_class.new(date_range: date_range)
      expect(query.new_requests_submitted_count).to eq(1)
    end
  end

  describe '#reopenings_submitted_count' do
    let!(:request_with_reopening) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: Date.new(2025, 5, 1)).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Date.new(2025, 5, 1))
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Date.new(2025, 5, 2))
        create(:authorization_request_event, :reopen, authorization_request: ar, user: user, created_at: Date.new(2025, 6, 1))
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Date.new(2025, 6, 2))
      end
    end

    it 'counts reopenings followed by submit in date range' do
      query = described_class.new(date_range: date_range)
      expect(query.reopenings_submitted_count).to eq(1)
    end
  end

  describe '#validations_count' do
    let!(:validated_request) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: Date.new(2025, 5, 1)).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Date.new(2025, 5, 1))
        create(:authorization_request_event, :approve, authorization_request: ar, user: user, created_at: Date.new(2025, 6, 15))
      end
    end

    it 'counts validation events in date range' do
      query = described_class.new(date_range: date_range)
      expect(query.validations_count).to eq(1)
    end
  end

  describe '#refusals_count' do
    let!(:refused_request) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: Date.new(2025, 5, 1)).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Date.new(2025, 5, 1))
        create(:authorization_request_event, :refuse, authorization_request: ar, user: user, created_at: Date.new(2025, 6, 15))
      end
    end

    it 'counts refusal events in date range' do
      query = described_class.new(date_range: date_range)
      expect(query.refusals_count).to eq(1)
    end
  end
end
