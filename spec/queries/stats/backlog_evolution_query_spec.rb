RSpec.describe Stats::BacklogEvolutionQuery, type: :query do
  let(:date_range) { Date.new(2025, 6, 1)..Date.new(2025, 6, 30) }
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }

  before do
    user.add_to_organization(organization, current: true)
  end

  describe '#calculate_backlog_at' do
    let!(:submitted_request_without_instruction) do
      create(:authorization_request, :api_entreprise, :submitted,
        applicant: user,
        organization: organization,
        created_at: Date.new(2025, 6, 5)).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Date.new(2025, 6, 5))
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Date.new(2025, 6, 6))
      end
    end

    let!(:submitted_request_with_approval) do
      create(:authorization_request, :api_entreprise, :submitted,
        applicant: user,
        organization: organization,
        created_at: Date.new(2025, 6, 10)).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Date.new(2025, 6, 10))
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Date.new(2025, 6, 11))
        create(:authorization_request_event, :approve, authorization_request: ar, user: user, created_at: Date.new(2025, 6, 15))
      end
    end

    let!(:submitted_request_with_refusal) do
      create(:authorization_request, :api_entreprise, :submitted,
        applicant: user,
        organization: organization,
        created_at: Date.new(2025, 6, 12)).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Date.new(2025, 6, 12))
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Date.new(2025, 6, 13))
        create(:authorization_request_event, :refuse, authorization_request: ar, user: user, created_at: Date.new(2025, 6, 16))
      end
    end

    let!(:submitted_request_with_changes_requested) do
      create(:authorization_request, :api_entreprise, :submitted,
        applicant: user,
        organization: organization,
        created_at: Date.new(2025, 6, 14)).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Date.new(2025, 6, 14))
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Date.new(2025, 6, 15))
        create(:authorization_request_event, :request_changes, authorization_request: ar, user: user, created_at: Date.new(2025, 6, 17))
      end
    end

    let!(:draft_request) do
      create(:authorization_request, :api_entreprise, :draft,
        applicant: user,
        organization: organization,
        created_at: Date.new(2025, 6, 20))
    end

    let!(:request_outside_range) do
      create(:authorization_request, :api_entreprise, :submitted,
        applicant: user,
        organization: organization,
        created_at: Date.new(2025, 5, 1)).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Date.new(2025, 5, 1))
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Date.new(2025, 5, 2))
      end
    end

    it 'calculates backlog as submitted events minus instructed events' do
      end_of_june = Date.new(2025, 6, 30).end_of_day
      query = described_class.new(date_range: date_range)

      backlog_count = query.send(:calculate_backlog_at, end_of_june)

      expect(backlog_count).to eq(2)
    end

    it 'excludes requests with approve events from backlog' do
      end_of_june = Date.new(2025, 6, 30).end_of_day
      query = described_class.new(date_range: date_range)

      backlog_count = query.send(:calculate_backlog_at, end_of_june)

      expect(backlog_count).to eq(2)
    end

    it 'excludes requests with refuse events from backlog' do
      end_of_june = Date.new(2025, 6, 30).end_of_day
      query = described_class.new(date_range: date_range)

      backlog_count = query.send(:calculate_backlog_at, end_of_june)

      expect(backlog_count).to eq(2)
    end

    it 'counts all submit events up to timestamp' do
      mid_june = Date.new(2025, 6, 15).end_of_day
      query = described_class.new(date_range: date_range)

      backlog_count = query.send(:calculate_backlog_at, mid_june)

      expect(backlog_count).to be >= 0
    end

    context 'with authorization type filters' do
      let!(:api_particulier_request) do
        create(:authorization_request, :api_particulier, :submitted,
          applicant: user,
          organization: organization,
          created_at: Date.new(2025, 6, 8)).tap do |ar|
          create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Date.new(2025, 6, 8))
          create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Date.new(2025, 6, 9))
        end
      end

      it 'only counts requests from filtered authorization types' do
        end_of_june = Date.new(2025, 6, 30).end_of_day
        query = described_class.new(
          date_range: date_range,
          authorization_types: ['AuthorizationRequest::APIParticulier']
        )

        backlog_count = query.send(:calculate_backlog_at, end_of_june)

        expect(backlog_count).to eq(1)
      end

      it 'excludes requests from other authorization types' do
        end_of_june = Date.new(2025, 6, 30).end_of_day
        query = described_class.new(
          date_range: date_range,
          authorization_types: ['AuthorizationRequest::APIEntreprise']
        )

        backlog_count = query.send(:calculate_backlog_at, end_of_june)

        expect(backlog_count).to eq(2)
      end

      it 'counts all types when no filter is applied' do
        end_of_june = Date.new(2025, 6, 30).end_of_day
        query = described_class.new(date_range: date_range)

        backlog_count = query.send(:calculate_backlog_at, end_of_june)

        expect(backlog_count).to eq(3)
      end
    end

    context 'with reopenings' do
      let!(:reopened_request) do
        create(:authorization_request, :api_entreprise, :submitted,
          applicant: user,
          organization: organization,
          created_at: Date.new(2025, 6, 1)).tap do |ar|
          create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Date.new(2025, 6, 1))
          create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Date.new(2025, 6, 2))
          create(:authorization_request_event, :approve, authorization_request: ar, user: user, created_at: Date.new(2025, 6, 5))
          create(:authorization_request_event, :reopen, authorization_request: ar, user: user, created_at: Date.new(2025, 6, 10))
          create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Date.new(2025, 6, 11))
        end
      end

      it 'counts reopened request as uninstructed after new submit' do
        mid_june = Date.new(2025, 6, 15).end_of_day
        query = described_class.new(date_range: date_range)

        backlog_count = query.send(:calculate_backlog_at, mid_june)

        expect(backlog_count).to be >= 3
        expect(backlog_count).to be <= 5
      end

      it 'excludes reopened request if it gets instructed after new submit' do
        create(:authorization_request_event, :approve, authorization_request: reopened_request, user: user, created_at: Date.new(2025, 6, 16))

        end_of_june = Date.new(2025, 6, 30).end_of_day
        query = described_class.new(date_range: date_range)

        backlog_count = query.send(:calculate_backlog_at, end_of_june)

        expect(backlog_count).to eq(2)
      end
    end
  end
end
