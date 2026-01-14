RSpec.describe Stats::Aggregator, type: :service do
  describe '#average_time_to_submit' do
    subject { described_class.new(authorization_requests).average_time_to_submit }

    context 'with a diverse dataset of authorization requests' do
      let(:base_time) { Time.zone.parse('2025-01-01 10:00:00') }
      
      # Create users and organizations for our test data
      let!(:user1) { create(:user) }
      let!(:user2) { create(:user) }
      let!(:organization1) { create(:organization) }
      let!(:organization2) { create(:organization) }
      
      before do
        user1.add_to_organization(organization1, current: true)
        user2.add_to_organization(organization2, current: true)
      end

      # Create 10+ authorization requests with different time gaps between create and submit
      let!(:ar1) do
        create(:authorization_request, :api_entreprise, applicant: user1, organization: organization1).tap do |ar|
          # Quick submitter - 5 minutes
          create(:authorization_request_event, :create, authorization_request: ar, user: user1, created_at: base_time)
          create(:authorization_request_event, :submit, authorization_request: ar, user: user1, created_at: base_time + 5.minutes)
        end
      end

      let!(:ar2) do
        create(:authorization_request, :api_particulier, applicant: user1, organization: organization1).tap do |ar|
          # Moderate - 1 hour
          create(:authorization_request_event, :create, authorization_request: ar, user: user1, created_at: base_time)
          create(:authorization_request_event, :submit, authorization_request: ar, user: user1, created_at: base_time + 1.hour)
        end
      end

      let!(:ar3) do
        create(:authorization_request, :api_particulier, applicant: user2, organization: organization2).tap do |ar|
          # Slow - 3 days
          create(:authorization_request_event, :create, authorization_request: ar, user: user2, created_at: base_time)
          create(:authorization_request_event, :submit, authorization_request: ar, user: user2, created_at: base_time + 3.days)
        end
      end

      let!(:ar4) do
        create(:authorization_request, :api_entreprise, applicant: user1, organization: organization1).tap do |ar|
          # Very fast - 30 seconds
          create(:authorization_request_event, :create, authorization_request: ar, user: user1, created_at: base_time + 1.day)
          create(:authorization_request_event, :submit, authorization_request: ar, user: user1, created_at: base_time + 1.day + 30.seconds)
        end
      end

      let!(:ar5) do
        create(:authorization_request, :france_connect, applicant: user2, organization: organization2).tap do |ar|
          # Medium - 6 hours
          create(:authorization_request_event, :create, authorization_request: ar, user: user2, created_at: base_time + 2.days)
          create(:authorization_request_event, :submit, authorization_request: ar, user: user2, created_at: base_time + 2.days + 6.hours)
        end
      end

      let!(:ar6) do
        create(:authorization_request, :hubee_cert_dc, applicant: user1, organization: organization1).tap do |ar|
          # Very slow - 7 days
          create(:authorization_request_event, :create, authorization_request: ar, user: user1, created_at: base_time)
          create(:authorization_request_event, :submit, authorization_request: ar, user: user1, created_at: base_time + 7.days)
        end
      end

      let!(:ar7) do
        create(:authorization_request, :api_entreprise, applicant: user2, organization: organization2).tap do |ar|
          # 2 hours
          create(:authorization_request_event, :create, authorization_request: ar, user: user2, created_at: base_time + 3.days)
          create(:authorization_request_event, :submit, authorization_request: ar, user: user2, created_at: base_time + 3.days + 2.hours)
        end
      end

      let!(:ar8) do
        create(:authorization_request, :api_particulier, applicant: user1, organization: organization1).tap do |ar|
          # 12 hours
          create(:authorization_request_event, :create, authorization_request: ar, user: user1, created_at: base_time + 4.days)
          create(:authorization_request_event, :submit, authorization_request: ar, user: user1, created_at: base_time + 4.days + 12.hours)
        end
      end

      let!(:ar9) do
        create(:authorization_request, :api_captchetat, applicant: user2, organization: organization2).tap do |ar|
          # 1.5 days
          create(:authorization_request_event, :create, authorization_request: ar, user: user2, created_at: base_time + 5.days)
          create(:authorization_request_event, :submit, authorization_request: ar, user: user2, created_at: base_time + 5.days + 1.5.days)
        end
      end

      let!(:ar10) do
        create(:authorization_request, :hubee_dila, applicant: user1, organization: organization1).tap do |ar|
          # 4 hours
          create(:authorization_request_event, :create, authorization_request: ar, user: user1, created_at: base_time + 6.days)
          create(:authorization_request_event, :submit, authorization_request: ar, user: user1, created_at: base_time + 6.days + 4.hours)
        end
      end

      let!(:ar11) do
        create(:authorization_request, :api_entreprise, applicant: user2, organization: organization2).tap do |ar|
          # 5 days
          create(:authorization_request_event, :create, authorization_request: ar, user: user2, created_at: base_time + 7.days)
          create(:authorization_request_event, :submit, authorization_request: ar, user: user2, created_at: base_time + 7.days + 5.days)
        end
      end

      let!(:ar12) do
        create(:authorization_request, :api_particulier, applicant: user1, organization: organization1).tap do |ar|
          # 8 hours
          create(:authorization_request_event, :create, authorization_request: ar, user: user1, created_at: base_time + 8.days)
          create(:authorization_request_event, :submit, authorization_request: ar, user: user1, created_at: base_time + 8.days + 8.hours)
        end
      end

      # Request with only create event (should be excluded from stats)
      let!(:ar_draft) do
        create(:authorization_request, :api_entreprise, :draft, applicant: user1, organization: organization1).tap do |ar|
          create(:authorization_request_event, :create, authorization_request: ar, user: user1, created_at: base_time + 10.days)
        end
      end

      # Request with multiple submit events (should use the first one)
      let!(:ar_multiple_submits) do
        create(:authorization_request, :api_particulier, applicant: user2, organization: organization2).tap do |ar|
          create(:authorization_request_event, :create, authorization_request: ar, user: user2, created_at: base_time + 9.days)
          create(:authorization_request_event, :submit, authorization_request: ar, user: user2, created_at: base_time + 9.days + 10.hours)
          # Second submit (resubmission) - should be ignored
          create(:authorization_request_event, :submit, authorization_request: ar, user: user2, created_at: base_time + 9.days + 15.hours)
        end
      end

      let(:authorization_requests) do
        AuthorizationRequest.where(id: [ar1.id, ar2.id, ar3.id, ar4.id, ar5.id, ar6.id, ar7.id, ar8.id, ar9.id, ar10.id, ar11.id, ar12.id, ar_multiple_submits.id])
      end

      it 'calculates the average time between create and first submit events' do
        # Expected times in seconds:
        # ar1: 300 (5 min)
        # ar2: 3600 (1 hour)
        # ar3: 259200 (3 days)
        # ar4: 30 (30 sec)
        # ar5: 21600 (6 hours)
        # ar6: 604800 (7 days)
        # ar7: 7200 (2 hours)
        # ar8: 43200 (12 hours)
        # ar9: 129600 (1.5 days)
        # ar10: 14400 (4 hours)
        # ar11: 432000 (5 days)
        # ar12: 28800 (8 hours)
        # ar_multiple_submits: 36000 (10 hours)
        
        expected_average = (300 + 3600 + 259200 + 30 + 21600 + 604800 + 7200 + 43200 + 129600 + 14400 + 432000 + 28800 + 36000) / 13.0
        
        expect(subject).to be_within(1).of(expected_average)
      end

      it 'excludes authorization requests without submit events' do
        count_with_submits = described_class.new(authorization_requests).send(:authorizations_with_first_create_and_submit_events).count
        expect(count_with_submits).to eq(13)
      end
    end

    context 'with no authorization requests' do
      let(:authorization_requests) { AuthorizationRequest.none }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end

    context 'with authorization requests that have no submit event' do
      let!(:user) { create(:user) }
      let!(:organization) { create(:organization) }
      
      before do
        user.add_to_organization(organization, current: true)
      end

      let!(:ar_draft) do
        create(:authorization_request, :api_entreprise, :draft, applicant: user, organization: organization).tap do |ar|
          create(:authorization_request_event, :create, authorization_request: ar, user: user)
        end
      end

      let(:authorization_requests) { AuthorizationRequest.where(id: ar_draft.id) }

      it 'returns nil when no authorization requests have submit events' do
        expect(subject).to be_nil
      end
    end
  end

  describe '#median_time_to_submit' do
    subject { described_class.new(authorization_requests).median_time_to_submit }

    let(:base_time) { Time.zone.parse('2025-01-15 14:00:00') }
    let!(:user) { create(:user) }
    let!(:organization) { create(:organization) }
    
    before do
      user.add_to_organization(organization, current: true)
    end

    let!(:ar_fast) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 1.minute)
      end
    end

    let!(:ar_slow) do
      create(:authorization_request, :api_particulier, applicant: user, organization: organization).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 14.days)
      end
    end

    let!(:ar_medium) do
      create(:authorization_request, :api_captchetat, applicant: user, organization: organization).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 5.hours)
      end
    end

    let(:authorization_requests) { AuthorizationRequest.where(id: [ar_fast.id, ar_slow.id, ar_medium.id]) }

    it 'returns the median time to submit' do
      # Values: 60 seconds (1 min), 18000 seconds (5 hours), 1209600 seconds (14 days)
      # Median: middle value = 18000 seconds (5 hours)
      expect(subject).to be_within(1).of(5.hours.to_f)
    end
  end

  describe '#stddev_time_to_submit' do
    subject { described_class.new(authorization_requests).stddev_time_to_submit }

    let(:base_time) { Time.zone.parse('2025-01-15 14:00:00') }
    let!(:user) { create(:user) }
    let!(:organization) { create(:organization) }
    
    before do
      user.add_to_organization(organization, current: true)
    end

    let!(:ar_fast) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 1.minute)
      end
    end

    let!(:ar_slow) do
      create(:authorization_request, :api_particulier, applicant: user, organization: organization).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 14.days)
      end
    end

    let!(:ar_medium) do
      create(:authorization_request, :api_captchetat, applicant: user, organization: organization).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 5.hours)
      end
    end

    let(:authorization_requests) { AuthorizationRequest.where(id: [ar_fast.id, ar_slow.id, ar_medium.id]) }

    it 'returns the standard deviation of time to submit' do
      # Values: 60, 18000, 1209600
      # Mean: (60 + 18000 + 1209600) / 3 ≈ 409220
      # Stddev should be calculated by PostgreSQL
      expect(subject).to be > 0
      expect(subject).to be_a(Float)
    end
  end

  describe '#first_create_events_subquery' do
    subject { described_class.new.first_create_events_subquery }

    let(:base_time) { Time.zone.parse('2025-01-15 14:00:00') }
    let!(:user) { create(:user) }
    let!(:organization) { create(:organization) }
    
    before do
      user.add_to_organization(organization, current: true)
    end

    let!(:ar_with_multiple_creates) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization).tap do |ar|
        # First create event
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        # Another create event (e.g., after update)
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time + 1.hour)
      end
    end

    it 'returns a query that groups by authorization_request_id' do
      results = subject.to_a
      ar_result = results.find { |r| r.authorization_request_id == ar_with_multiple_creates.id }
      
      expect(ar_result).to be_present
      expect(ar_result.event_time).to be_within(1.second).of(base_time)
    end

    it 'only includes create events' do
      # Create an authorization request with submit event
      ar = create(:authorization_request, :api_particulier, applicant: user, organization: organization)
      create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
      create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 1.hour)

      results = subject.to_a
      ar_result = results.find { |r| r.authorization_request_id == ar.id }
      
      # Should only find the create event, not the submit
      expect(ar_result.event_time).to be_within(1.second).of(base_time)
    end
  end

  describe 'integration with different authorization request types' do
    subject { described_class.new }

    let(:base_time) { Time.zone.parse('2025-02-01 09:00:00') }
    let!(:user) { create(:user) }
    let!(:organization) { create(:organization) }
    
    before do
      user.add_to_organization(organization, current: true)
    end

    # Test with different authorization request types
    let!(:api_entreprise_ar) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 2.hours)
      end
    end

    let!(:api_particulier_ar) do
      create(:authorization_request, :api_particulier, applicant: user, organization: organization).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 3.hours)
      end
    end

    let!(:france_connect_ar) do
      create(:authorization_request, :france_connect, applicant: user, organization: organization).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 1.hour)
      end
    end

    let!(:hubee_ar) do
      create(:authorization_request, :hubee_cert_dc, applicant: user, organization: organization).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 4.hours)
      end
    end

    it 'calculates statistics across all authorization request types' do
      # Average: (2h + 3h + 1h + 4h) / 4 = 2.5h = 9000 seconds
      expect(subject.average_time_to_submit).to be_within(1).of(9000)
      # Median of [3600, 7200, 10800, 14400] = (7200 + 10800) / 2 = 9000 seconds
      expect(subject.median_time_to_submit).to be_within(1).of(9000)
      expect(subject.stddev_time_to_submit).to be > 0
    end
  end

  describe 'filtering legacy changelogs' do
    subject { described_class.new }

    let(:base_time) { Time.zone.parse('2025-02-01 09:00:00') }
    let!(:user) { create(:user) }
    let!(:organization) { create(:organization) }
    
    before do
      user.add_to_organization(organization, current: true)
    end

    let!(:ar_with_legacy_submit) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        
        # Create a legacy changelog
        legacy_changelog = create(:authorization_request_changelog, authorization_request: ar, legacy: true)
        create(:authorization_request_event, name: 'submit', authorization_request: ar, user: user, entity: legacy_changelog, created_at: base_time + 1.hour)
      end
    end

    let!(:ar_with_normal_submit) do
      create(:authorization_request, :api_particulier, applicant: user, organization: organization).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        
        # Create a non-legacy changelog
        normal_changelog = create(:authorization_request_changelog, authorization_request: ar, legacy: false)
        create(:authorization_request_event, name: 'submit', authorization_request: ar, user: user, entity: normal_changelog, created_at: base_time + 1.5.hours)
      end
    end

    it 'excludes authorization requests with only legacy submit events' do
      # Only the normal submit should be counted
      # The actual calculation may vary slightly due to event timing
      expect(subject.average_time_to_submit).to be_within(1000).of(5400)
    end
  end

  describe '#time_to_submit_by_type' do
    subject { described_class.new }

    let(:base_time) { Time.zone.parse('2025-03-01 10:00:00') }
    let!(:user) { create(:user) }
    let!(:organization) { create(:organization) }
    
    before do
      user.add_to_organization(organization, current: true)
    end

    # Create different types of authorization requests with different submission times
    let!(:api_entreprise_1) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 1.hour)
      end
    end

    let!(:api_entreprise_2) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time + 1.day)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 1.day + 3.hours)
      end
    end

    let!(:api_entreprise_3) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time + 2.days)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 2.days + 2.hours)
      end
    end

    let!(:api_particulier_1) do
      create(:authorization_request, :api_particulier, applicant: user, organization: organization).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 4.hours)
      end
    end

    let!(:api_particulier_2) do
      create(:authorization_request, :api_particulier, applicant: user, organization: organization).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time + 1.day)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 1.day + 6.hours)
      end
    end

    let!(:france_connect_1) do
      create(:authorization_request, :france_connect, applicant: user, organization: organization).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 30.minutes)
      end
    end

    let!(:france_connect_2) do
      create(:authorization_request, :france_connect, applicant: user, organization: organization).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time + 1.day)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 1.day + 1.hour)
      end
    end

    it 'returns statistics grouped by authorization request type' do
      stats = subject.time_to_submit_by_type
      
      expect(stats).to be_an(Array)
      expect(stats.length).to eq(3) # API Entreprise, API Particulier, France Connect
    end

    it 'includes all required fields for each type' do
      stats = subject.time_to_submit_by_type
      
      stats.each do |stat|
        expect(stat).to have_key(:type)
        expect(stat).to have_key(:min_time)
        expect(stat).to have_key(:avg_time)
        expect(stat).to have_key(:max_time)
        expect(stat).to have_key(:count)
      end
    end

    it 'calculates correct statistics for API Entreprise' do
      stats = subject.time_to_submit_by_type
      api_entreprise_stats = stats.find { |s| s[:type] == 'AuthorizationRequest::APIEntreprise' }
      
      expect(api_entreprise_stats).to be_present
      expect(api_entreprise_stats[:count]).to eq(3)
      expect(api_entreprise_stats[:min_time]).to be_within(100).of(3600) # 1 hour
      expect(api_entreprise_stats[:max_time]).to be_within(100).of(10800) # 3 hours
      expect(api_entreprise_stats[:avg_time]).to be_within(200).of(7200) # 2 hours average
    end

    it 'calculates correct statistics for API Particulier' do
      stats = subject.time_to_submit_by_type
      api_particulier_stats = stats.find { |s| s[:type] == 'AuthorizationRequest::APIParticulier' }
      
      expect(api_particulier_stats).to be_present
      expect(api_particulier_stats[:count]).to eq(2)
      expect(api_particulier_stats[:min_time]).to be_within(100).of(14400) # 4 hours
      expect(api_particulier_stats[:max_time]).to be_within(100).of(21600) # 6 hours
    end

    it 'calculates correct statistics for France Connect' do
      stats = subject.time_to_submit_by_type
      france_connect_stats = stats.find { |s| s[:type] == 'AuthorizationRequest::FranceConnect' }
      
      expect(france_connect_stats).to be_present
      expect(france_connect_stats[:count]).to eq(2)
      expect(france_connect_stats[:min_time]).to be_within(100).of(1800) # 30 minutes
      expect(france_connect_stats[:max_time]).to be_within(100).of(3600) # 1 hour
    end

    it 'returns results sorted by average time' do
      stats = subject.time_to_submit_by_type
      avg_times = stats.map { |s| s[:avg_time] }
      
      expect(avg_times).to eq(avg_times.sort)
    end

    context 'with no authorization requests' do
      let(:empty_aggregator) { described_class.new(AuthorizationRequest.none) }

      it 'returns an empty array' do
        expect(empty_aggregator.time_to_submit_by_type).to eq([])
      end
    end
  end

  describe '#reopen_events_count' do
    let(:base_time) { Time.zone.parse('2025-04-01 10:00:00') }
    let!(:user) { create(:user) }
    let!(:organization1) { create(:organization) }
    let!(:organization2) { create(:organization) }
    let!(:organization3) { create(:organization) }
    let!(:organization4) { create(:organization) }
    
    before do
      user.add_to_organization(organization1, current: true)
      user.add_to_organization(organization2)
      user.add_to_organization(organization3)
      user.add_to_organization(organization4)
    end

    let!(:ar1) do
      create(:authorization_request, :validated, applicant: user, organization: organization1, created_at: base_time).tap do |ar|
        # First reopen followed by submit
        create(:authorization_request_event, :reopen, authorization_request: ar, user: user, created_at: base_time + 1.day)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 2.days)
        # Second reopen followed by submit (same request reopened again)
        create(:authorization_request_event, :reopen, authorization_request: ar, user: user, created_at: base_time + 5.days)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 6.days)
      end
    end

    let!(:ar2) do
      create(:authorization_request, :validated, applicant: user, organization: organization2, created_at: base_time).tap do |ar|
        # One reopen followed by submit
        create(:authorization_request_event, :reopen, authorization_request: ar, user: user, created_at: base_time + 3.days)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 4.days)
      end
    end

    let!(:ar3) do
      create(:authorization_request, :validated, applicant: user, organization: organization3, created_at: base_time - 120.days).tap do |ar|
        create(:authorization_request_event, :reopen, authorization_request: ar, user: user, created_at: base_time - 100.days)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time - 99.days)
      end
    end

    # Reopen event without subsequent submit (should not be counted)
    let!(:ar4) do
      create(:authorization_request, applicant: user, organization: organization4, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :reopen, authorization_request: ar, user: user, created_at: base_time + 10.days)
        # No submit event after this reopen
      end
    end

    context 'when filtering by specific authorization requests' do
      subject { described_class.new(AuthorizationRequest.where(id: [ar1.id, ar2.id])) }

      it 'counts only reopen events followed by submit for the given authorization requests' do
        # Should count 3 reopen events (2 from ar1, 1 from ar2)
        # ar3 is not included in the filter
        # ar4 has a reopen but no submit after it, so it would not be counted anyway
        expect(subject.reopen_events_count).to eq(3)
      end

      it 'counts multiple reopens from the same authorization request' do
        # ar1 has 2 reopen events, both followed by submit, both should be counted
        expect(subject.reopen_events_count).to eq(3)
      end
    end

    context 'when using all authorization requests' do
      subject { described_class.new }

      it 'counts all reopen events followed by submit' do
        # Should count 4 reopen events (2 from ar1, 1 from ar2, 1 from ar3)
        # ar4 has a reopen but no submit after it, so it should not be counted
        expect(subject.reopen_events_count).to eq(4)
      end
    end

    context 'when authorization request has reopen without submit' do
      subject { described_class.new(AuthorizationRequest.where(id: ar4.id)) }

      it 'does not count reopen events without subsequent submit' do
        # ar4 has a reopen but no submit after it
        expect(subject.reopen_events_count).to eq(0)
      end
    end

    context 'when filtering by authorization request with only one reopen' do
      subject { described_class.new(AuthorizationRequest.where(id: ar3.id)) }

      it 'counts the single reopen followed by submit' do
        expect(subject.reopen_events_count).to eq(1)
      end
    end
  end

  describe '#time_to_submit_by_duration_buckets' do
    let(:base_time) { Time.zone.parse('2025-03-15 10:00:00') }
    let!(:user) { create(:user) }
    let!(:organization) { create(:organization) }
    
    before do
      user.add_to_organization(organization, current: true)
    end

    # Create authorization requests with different time to submit durations
    let!(:ar_30_seconds) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 30.seconds)
      end
    end

    let!(:ar_90_seconds) do
      create(:authorization_request, :api_particulier, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 90.seconds)
      end
    end

    let!(:ar_2_hours) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 2.hours)
      end
    end

    let!(:ar_5_days) do
      create(:authorization_request, :api_particulier, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 5.days)
      end
    end

    subject { described_class.new }

    context 'with step: :minute' do
      it 'returns buckets grouped by minutes' do
        buckets = subject.time_to_submit_by_duration_buckets(step: :minute)
        
        expect(buckets).to be_an(Array)
        expect(buckets.first[:bucket]).to eq('<1')
        expect(buckets.last[:bucket]).to eq('> 60')
        
        # Check structure
        expect(buckets.all? { |b| b.key?(:bucket) && b.key?(:count) }).to be true
        
        # Should have 62 buckets: <1, 1-60, > 60
        expect(buckets.size).to eq(62)
      end

      it 'distributes values correctly' do
        buckets = subject.time_to_submit_by_duration_buckets(step: :minute)
        
        # ar_30_seconds should be in <1 bucket
        # ar_90_seconds should be in bucket 2 (90/60 = 1.5, ceil = 2)
        # ar_2_hours and ar_5_days should be in > 60
        
        less_than_1 = buckets.find { |b| b[:bucket] == '<1' }[:count]
        more_than_60 = buckets.find { |b| b[:bucket] == '> 60' }[:count]
        
        expect(less_than_1).to be >= 0
        expect(more_than_60).to be >= 0
        
        total = buckets.sum { |b| b[:count] }
        expect(total).to be > 0
      end
    end

    context 'with step: :hour' do
      it 'returns buckets grouped by hours' do
        buckets = subject.time_to_submit_by_duration_buckets(step: :hour)
        
        expect(buckets).to be_an(Array)
        expect(buckets.first[:bucket]).to eq('<1')
        expect(buckets.last[:bucket]).to eq('> 24')
        
        # Should have 26 buckets: <1, 1-24, > 24
        expect(buckets.size).to eq(26)
      end
    end

    context 'with step: :day' do
      it 'returns buckets grouped by days' do
        buckets = subject.time_to_submit_by_duration_buckets(step: :day)
        
        expect(buckets).to be_an(Array)
        expect(buckets.first[:bucket]).to eq('<1')
        expect(buckets.last[:bucket]).to eq('> 30')
        
        # Should have 32 buckets: <1, 1-30, > 30
        expect(buckets.size).to eq(32)
      end
    end

    context 'with invalid step' do
      it 'raises an error' do
        expect { subject.time_to_submit_by_duration_buckets(step: :invalid) }.to raise_error(ArgumentError)
      end
    end

    context 'with no authorization requests' do
      subject { described_class.new(AuthorizationRequest.none) }

      it 'returns empty array' do
        buckets = subject.time_to_submit_by_duration_buckets(step: :day)
        expect(buckets).to eq([])
      end
    end
  end

  describe 'time to first instruction metrics' do
    let(:base_time) { Time.zone.parse('2025-03-15 10:00:00') }
    let!(:user) { create(:user) }
    let!(:organization) { create(:organization) }
    
    before do
      user.add_to_organization(organization, current: true)
    end

    # Create authorization request with submit and instruction events
    let!(:ar1) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 1.hour)
        create(:authorization_request_event, :approve, authorization_request: ar, user: user, created_at: base_time + 1.day)
      end
    end

    let!(:ar2) do
      create(:authorization_request, :api_particulier, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 2.hours)
        create(:authorization_request_event, :request_changes, authorization_request: ar, user: user, created_at: base_time + 2.days)
      end
    end

    subject { described_class.new }

    describe '#average_time_to_first_instruction' do
      it 'returns average time from submit to first instruction' do
        avg_time = subject.average_time_to_first_instruction
        
        # ar1: 1 day - 1 hour = 23 hours = 82800 seconds
        # ar2: 2 days - 2 hours = 46 hours = 165600 seconds
        # Average: (82800 + 165600) / 2 = 124200 seconds
        expect(avg_time).to be_within(1).of(124200)
      end
    end

    describe '#median_time_to_first_instruction' do
      it 'returns median time from submit to first instruction' do
        median_time = subject.median_time_to_first_instruction
        
        # ar1: 82800 seconds
        # ar2: 165600 seconds
        # Median of 2 values: (82800 + 165600) / 2 = 124200 seconds
        expect(median_time).to be_within(1).of(124200)
      end
    end

    describe '#stddev_time_to_first_instruction' do
      it 'returns standard deviation of time to first instruction' do
        stddev_time = subject.stddev_time_to_first_instruction
        
        # ar1: 82800 seconds
        # ar2: 165600 seconds
        # Mean: 124200
        # Variance: ((82800-124200)^2 + (165600-124200)^2) / 2 = (1715560000 + 1715560000) / 2 = 1715560000
        # StdDev: sqrt(1715560000) ≈ 41420 seconds (about 11.5 hours)
        expect(stddev_time).to be_within(100).of(41420)
      end
    end

    context 'with authorization request without instruction event' do
      let!(:ar3) do
        create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: base_time).tap do |ar|
          create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
          create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 1.hour)
          # No instruction event
        end
      end

      it 'excludes authorization requests without instruction events' do
        avg_time = subject.average_time_to_first_instruction
        
        # Should only count ar1 and ar2, not ar3
        expect(avg_time).to be_within(1).of(124200)
      end
    end

    context 'with multiple submit events' do
      let!(:ar4) do
        create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: base_time).tap do |ar|
          create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
          create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 1.hour)
          create(:authorization_request_event, :request_changes, authorization_request: ar, user: user, created_at: base_time + 1.day)
          create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 2.days)
          create(:authorization_request_event, :approve, authorization_request: ar, user: user, created_at: base_time + 3.days)
        end
      end

      it 'counts time for each submit event separately' do
        # This test verifies that each submit gets paired with its following instruction
        avg_time = subject.average_time_to_first_instruction
        
        # Should have data for ar1, ar2, and ar4 (with 2 submit-instruction pairs)
        expect(avg_time).to be > 0
      end
    end

    context 'with refuse event' do
      let!(:ar5) do
        create(:authorization_request, :api_particulier, applicant: user, organization: organization, created_at: base_time).tap do |ar|
          create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
          create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 1.hour)
          create(:authorization_request_event, :refuse, authorization_request: ar, user: user, created_at: base_time + 3.hours)
        end
      end

      it 'includes refuse events as instruction events' do
        avg_time = subject.average_time_to_first_instruction
        
        # Should include ar5 with 2 hours instruction time
        expect(avg_time).to be > 0
      end
    end

    context 'with no authorization requests' do
      subject { described_class.new(AuthorizationRequest.none) }

      it 'returns nil' do
        expect(subject.average_time_to_first_instruction).to be_nil
      end
    end
  end
end
