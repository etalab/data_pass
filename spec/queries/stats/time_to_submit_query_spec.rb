RSpec.describe Stats::TimeToSubmitQuery, type: :query do
  let(:date_range) { Date.new(2025, 1, 1)..Date.new(2025, 12, 31) }
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }

  before do
    user.add_to_organization(organization, current: true)
  end

  describe '#percentiles' do
    let!(:fast_request) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: Date.new(2025, 6, 1)).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 1, 10, 0))
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 1, 12, 0))
      end
    end

    let!(:slow_request) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: Date.new(2025, 6, 2)).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 2, 10, 0))
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 2, 14, 0))
      end
    end

    it 'calculates both percentiles of time between create and submit events' do
      query = described_class.new(date_range: date_range)
      result = query.percentiles

      expect(result[:p50]).to be_a(Numeric)
      expect(result[:p50]).to be > 0
      expect(result[:p50]).to be_between(2.hours.to_i, 4.hours.to_i)
      expect(result[:p90]).to be_a(Numeric)
      expect(result[:p90]).to be >= result[:p50]
    end

    context 'with quasi-instantaneous requests' do
      let!(:instant_request) do
        create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: Date.new(2025, 6, 3)).tap do |ar|
          create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 3, 10, 0, 0))
          create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 3, 10, 0, 10))
        end
      end

      it 'filters out quasi-instantaneous durations from percentile calculation' do
        query = described_class.new(date_range: date_range)
        result = query.percentiles

        expect(result[:p50]).to be_a(Numeric)
        expect(result[:p50]).to be > 60
        expect(result[:p50]).to be_between(2.hours.to_i, 4.hours.to_i)
      end
    end

    context 'with no data' do
      let(:empty_date_range) { Date.new(2024, 1, 1)..Date.new(2024, 1, 31) }

      it 'returns nil for both percentiles' do
        query = described_class.new(date_range: empty_date_range)
        result = query.percentiles

        expect(result[:p50]).to be_nil
        expect(result[:p90]).to be_nil
      end
    end

    context 'with only quasi-instantaneous requests' do
      let!(:first_instant_request) do
        create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: Date.new(2025, 6, 3)).tap do |ar|
          create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 3, 10, 0, 0))
          create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 3, 10, 0, 10))
        end
      end

      let!(:second_instant_request) do
        create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: Date.new(2025, 6, 4)).tap do |ar|
          create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 4, 10, 0, 0))
          create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 4, 10, 0, 5))
        end
      end

      let(:only_instant_date_range) { Date.new(2025, 6, 3)..Date.new(2025, 6, 5) }

      it 'returns nil when all requests are filtered out' do
        query = described_class.new(date_range: only_instant_date_range)
        result = query.percentiles

        expect(result[:p50]).to be_nil
        expect(result[:p90]).to be_nil
      end
    end

    context 'with enough data for meaningful 90th percentile' do
      let!(:medium_request) do
        create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: Date.new(2025, 6, 3)).tap do |ar|
          create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 3, 10, 0))
          create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 3, 14, 0))
        end
      end

      let!(:very_slow_request) do
        create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: Date.new(2025, 6, 4)).tap do |ar|
          create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 4, 10, 0))
          create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 4, 16, 0))
        end
      end

      it 'calculates 90th percentile higher than or equal to 50th percentile' do
        query = described_class.new(date_range: date_range)
        result = query.percentiles

        expect(result[:p90]).to be_a(Numeric)
        expect(result[:p90]).to be > 0
        expect(result[:p90]).to be >= result[:p50]
        expect(result[:p90]).to be_between(2.hours.to_i, 6.hours.to_i)
      end
    end
  end
end
