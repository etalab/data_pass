RSpec.describe Stats::TimeToSubmitQuery, type: :query do
  let(:date_range) { Date.new(2025, 1, 1)..Date.new(2025, 12, 31) }
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }

  before do
    user.add_to_organization(organization, current: true)
  end

  describe '#median' do
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

    it 'calculates median time between create and submit events' do
      query = described_class.new(date_range: date_range)
      median = query.median

      expect(median).to be_a(Numeric)
      expect(median).to be > 0
      expect(median).to be_between(2.hours.to_i, 4.hours.to_i)
    end

    context 'with no data' do
      let(:empty_date_range) { Date.new(2024, 1, 1)..Date.new(2024, 1, 31) }

      it 'returns nil' do
        query = described_class.new(date_range: empty_date_range)
        expect(query.median).to be_nil
      end
    end
  end

  describe '#stddev' do
    let!(:request_with_events) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: Date.new(2025, 6, 1)).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 1, 10, 0))
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Time.zone.local(2025, 6, 1, 12, 0))
      end
    end

    it 'calculates standard deviation' do
      query = described_class.new(date_range: date_range)
      stddev = query.stddev

      expect(stddev).to be_a(Numeric).or(be_nil)
    end
  end
end
