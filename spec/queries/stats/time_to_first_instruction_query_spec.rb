RSpec.describe Stats::TimeToFirstInstructionQuery, type: :query do
  let(:date_range) { Date.new(2025, 1, 1)..Date.new(2025, 12, 31) }
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }

  before do
    user.add_to_organization(organization, current: true)
  end

  describe '#percentiles' do
    let!(:fast_instruction_request) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: Date.new(2025, 6, 1)).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 1, 10, 0))
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 1, 11, 0))
        create(:authorization_request_event, :approve, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 1, 14, 0))
      end
    end

    let!(:slow_instruction_request) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: Date.new(2025, 6, 2)).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 2, 10, 0))
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 2, 11, 0))
        create(:authorization_request_event, :request_changes, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 3, 11, 0))
      end
    end

    it 'calculates both percentiles of time between submit and first instruction' do
      query = described_class.new(date_range: date_range)
      result = query.percentiles

      expect(result[:p50]).to be_a(Numeric)
      expect(result[:p50]).to be > 0
      expect(result[:p50]).to be_between(3.hours.to_i, 24.hours.to_i)
      expect(result[:p80]).to be_a(Numeric)
      expect(result[:p80]).to be >= result[:p50]
    end

    context 'with no data' do
      let(:empty_date_range) { Date.new(2024, 1, 1)..Date.new(2024, 1, 31) }

      it 'returns nil for both percentiles' do
        query = described_class.new(date_range: empty_date_range)
        result = query.percentiles

        expect(result[:p50]).to be_nil
        expect(result[:p80]).to be_nil
      end
    end

    context 'with request_changes as first instruction' do
      it 'considers request_changes as a valid first instruction event' do
        query = described_class.new(date_range: date_range)

        expect(query.percentiles[:p50]).to be_present
      end
    end

    context 'with enough data for meaningful 80th percentile' do
      let!(:another_slow_request) do
        create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: Date.new(2025, 6, 3)).tap do |ar|
          create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 3, 10, 0))
          create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 3, 11, 0))
          create(:authorization_request_event, :refuse, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 5, 11, 0))
        end
      end

      it 'calculates 80th percentile higher than or equal to 50th percentile' do
        query = described_class.new(date_range: date_range)
        result = query.percentiles

        expect(result[:p80]).to be_a(Numeric)
        expect(result[:p80]).to be > 0
        expect(result[:p80]).to be_between(3.hours.to_i, 48.hours.to_i)
      end
    end
  end
end
