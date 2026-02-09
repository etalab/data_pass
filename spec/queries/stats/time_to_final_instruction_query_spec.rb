RSpec.describe Stats::TimeToFinalInstructionQuery, type: :query do
  let(:date_range) { Date.new(2025, 1, 1)..Date.new(2025, 12, 31) }
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }

  before do
    user.add_to_organization(organization, current: true)
  end

  describe '#percentiles' do
    let!(:fast_decision_request) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: Date.new(2025, 6, 1)).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 1, 10, 0))
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 1, 11, 0))
        create(:authorization_request_event, :approve, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 1, 15, 0))
      end
    end

    let!(:slow_decision_request) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: Date.new(2025, 6, 2)).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 2, 10, 0))
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 2, 11, 0))
        create(:authorization_request_event, :refuse, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 4, 11, 0))
      end
    end

    it 'calculates both percentiles of time between submit and final decision' do
      query = described_class.new(date_range: date_range)
      result = query.percentiles

      expect(result[:p50]).to be_a(Numeric)
      expect(result[:p50]).to be > 0
      expect(result[:p50]).to be_between(4.hours.to_i, 48.hours.to_i)
      expect(result[:p90]).to be_a(Numeric)
      expect(result[:p90]).to be >= result[:p50]
    end

    it 'only considers approve and refuse as final decisions' do
      query = described_class.new(date_range: date_range)

      expect(query.percentiles[:p50]).to be_present
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

    context 'with request_changes before final decision' do
      let!(:request_with_changes) do
        create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: Date.new(2025, 6, 5)).tap do |ar|
          create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 5, 10, 0))
          create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 5, 11, 0))
          create(:authorization_request_event, :request_changes, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 6, 11, 0))
          create(:authorization_request_event, :approve, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 8, 11, 0))
        end
      end

      it 'measures time to the first approve/refuse, not request_changes' do
        query = described_class.new(date_range: date_range)
        result = query.percentiles

        expect(result[:p50]).to be_present
        expect(result[:p50]).to be > 0
      end
    end

    context 'with enough data for meaningful 90th percentile' do
      let!(:medium_decision_request) do
        create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: Date.new(2025, 6, 3)).tap do |ar|
          create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 3, 10, 0))
          create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 3, 11, 0))
          create(:authorization_request_event, :refuse, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 5, 11, 0))
        end
      end

      let!(:very_slow_decision_request) do
        create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: Date.new(2025, 6, 5)).tap do |ar|
          create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 5, 10, 0))
          create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 5, 11, 0))
          create(:authorization_request_event, :approve, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 9, 11, 0))
        end
      end

      it 'calculates 90th percentile higher than or equal to 50th percentile' do
        query = described_class.new(date_range: date_range)
        result = query.percentiles

        expect(result[:p90]).to be_a(Numeric)
        expect(result[:p90]).to be > 0
        expect(result[:p90]).to be_between(4.hours.to_i, 96.hours.to_i)
      end
    end
  end
end
