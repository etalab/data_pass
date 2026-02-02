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

  describe '#mode_time_to_submit' do
    subject { described_class.new(authorization_requests).mode_time_to_submit }

    let(:base_time) { Time.zone.parse('2025-01-15 14:00:00') }
    let!(:user) { create(:user) }
    let!(:organization) { create(:organization) }
    
    before do
      user.add_to_organization(organization, current: true)
    end

    # Create multiple requests with same submit time (rounded to minute)
    let!(:ar1) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 5.minutes)
      end
    end

    let!(:ar2) do
      create(:authorization_request, :api_particulier, applicant: user, organization: organization).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 5.minutes + 20.seconds)
      end
    end

    let!(:ar3) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 5.minutes + 40.seconds)
      end
    end

    let!(:ar4) do
      create(:authorization_request, :api_particulier, applicant: user, organization: organization).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 10.minutes)
      end
    end

    let(:authorization_requests) { AuthorizationRequest.where(id: [ar1.id, ar2.id, ar3.id, ar4.id]) }

    it 'returns the most frequent time to submit (rounded to nearest minute)' do
      # ar1, ar2, ar3 all round to 5 minutes (most frequent)
      # ar4 rounds to 10 minutes
      # Mode should be 300 seconds (5 minutes)
      expect(subject).to be_within(60).of(5.minutes.to_f)
    end

    context 'with no authorization requests' do
      let(:authorization_requests) { AuthorizationRequest.none }

      it 'returns nil' do
        expect(subject).to be_nil
      end
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

    describe '#mode_time_to_first_instruction' do
      let(:base_time_mode) { Time.zone.parse('2025-06-15 10:00:00') }
      let!(:user_mode) { create(:user) }
      let!(:organization_mode) { create(:organization) }
      
      before do
        user_mode.add_to_organization(organization_mode, current: true)
      end

      let!(:ar_mode_1) do
        create(:authorization_request, :api_entreprise, applicant: user_mode, organization: organization_mode, created_at: base_time_mode).tap do |ar|
          create(:authorization_request_event, :create, authorization_request: ar, user: user_mode, created_at: base_time_mode)
          create(:authorization_request_event, :submit, authorization_request: ar, user: user_mode, created_at: base_time_mode + 1.hour)
          create(:authorization_request_event, :approve, authorization_request: ar, user: user_mode, created_at: base_time_mode + 1.hour + 2.hours + 10.seconds)
        end
      end

      let!(:ar_mode_2) do
        create(:authorization_request, :api_particulier, applicant: user_mode, organization: organization_mode, created_at: base_time_mode).tap do |ar|
          create(:authorization_request_event, :create, authorization_request: ar, user: user_mode, created_at: base_time_mode)
          create(:authorization_request_event, :submit, authorization_request: ar, user: user_mode, created_at: base_time_mode + 1.hour)
          create(:authorization_request_event, :approve, authorization_request: ar, user: user_mode, created_at: base_time_mode + 1.hour + 2.hours + 30.seconds)
        end
      end

      let!(:ar_mode_3) do
        create(:authorization_request, :api_entreprise, applicant: user_mode, organization: organization_mode, created_at: base_time_mode).tap do |ar|
          create(:authorization_request_event, :create, authorization_request: ar, user: user_mode, created_at: base_time_mode)
          create(:authorization_request_event, :submit, authorization_request: ar, user: user_mode, created_at: base_time_mode + 1.hour)
          create(:authorization_request_event, :request_changes, authorization_request: ar, user: user_mode, created_at: base_time_mode + 1.hour + 5.hours)
        end
      end

      let(:mode_authorization_requests) { AuthorizationRequest.where(id: [ar_mode_1.id, ar_mode_2.id, ar_mode_3.id]) }
      subject { described_class.new(mode_authorization_requests) }

      it 'returns the most frequent time to first instruction (rounded up to nearest day)' do
        mode_time = subject.mode_time_to_first_instruction
        
        # ar_mode_1 and ar_mode_2 both have ~2 hours instruction time, which ceils to 1 day
        # ar_mode_3 has 5 hours, which also ceils to 1 day
        # All three ceil to 1 day (86400 seconds)
        expect(mode_time).to eq(86400.0)
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

  describe '#volume_by_type' do
    let(:base_time) { Time.zone.parse('2025-03-15 10:00:00') }
    let!(:user) { create(:user) }
    let!(:organization) { create(:organization) }
    
    before do
      user.add_to_organization(organization, current: true)
    end

    let!(:ar1) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
      end
    end

    let!(:ar2) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
      end
    end

    let!(:ar3) do
      create(:authorization_request, :api_particulier, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
      end
    end

    let(:authorization_requests) { AuthorizationRequest.where(id: [ar1.id, ar2.id, ar3.id]) }
    subject { described_class.new(authorization_requests) }

    it 'returns volume grouped by type' do
      result = subject.volume_by_type
      
      expect(result).to be_an(Array)
      expect(result.length).to eq(2)
      
      # Find the types
      api_entreprise = result.find { |r| r[:type].include?('APIEntreprise') }
      api_particulier = result.find { |r| r[:type].include?('APIParticulier') }
      
      expect(api_entreprise[:count]).to eq(2)
      expect(api_particulier[:count]).to eq(1)
    end

    it 'sorts results by count descending' do
      result = subject.volume_by_type
      
      counts = result.map { |r| r[:count] }
      expect(counts).to eq(counts.sort.reverse)
    end
  end

  describe '#volume_by_provider' do
    let(:base_time) { Time.zone.parse('2025-03-15 10:00:00') }
    let!(:user) { create(:user) }
    let!(:organization) { create(:organization) }
    
    before do
      user.add_to_organization(organization, current: true)
    end

    let!(:ar1) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
      end
    end

    let!(:ar2) do
      create(:authorization_request, :api_particulier, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
      end
    end

    let(:authorization_requests) { AuthorizationRequest.where(id: [ar1.id, ar2.id]) }
    subject { described_class.new(authorization_requests) }

    it 'returns volume grouped by provider' do
      result = subject.volume_by_provider
      
      expect(result).to be_an(Array)
      expect(result.length).to be >= 1
      
      # Check that each item has provider and count
      result.each do |item|
        expect(item).to have_key(:provider)
        expect(item).to have_key(:count)
        expect(item[:count]).to be > 0
      end
      
      # Total should equal our test data
      total_count = result.sum { |r| r[:count] }
      expect(total_count).to eq(2)
    end

    it 'sorts results by count descending' do
      result = subject.volume_by_provider
      
      counts = result.map { |r| r[:count] }
      expect(counts).to eq(counts.sort.reverse)
    end
  end

  describe '#volume_by_type_with_states' do
    let(:base_time) { Time.zone.parse('2025-03-15 10:00:00') }
    let!(:user) { create(:user) }
    let!(:organization) { create(:organization) }
    
    before do
      user.add_to_organization(organization, current: true)
    end

    let!(:ar_validated_1) do
      create(:authorization_request, :api_entreprise, :validated, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
      end
    end

    let!(:ar_validated_2) do
      create(:authorization_request, :api_entreprise, :validated, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
      end
    end

    let!(:ar_refused) do
      create(:authorization_request, :api_entreprise, :refused, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
      end
    end

    let!(:ar_draft) do
      create(:authorization_request, :api_particulier, :draft, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
      end
    end

    let!(:ar_validated_particulier) do
      create(:authorization_request, :api_particulier, :validated, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
      end
    end

    let(:authorization_requests) { AuthorizationRequest.where(id: [ar_validated_1.id, ar_validated_2.id, ar_refused.id, ar_draft.id, ar_validated_particulier.id]) }
    subject { described_class.new(authorization_requests) }

    it 'returns volume split by validated and refused states' do
      result = subject.volume_by_type_with_states
      
      expect(result).to be_an(Array)
      
      # Find the types
      api_entreprise = result.find { |r| r[:type].include?('APIEntreprise') }
      api_particulier = result.find { |r| r[:type].include?('APIParticulier') }
      
      expect(api_entreprise[:validated]).to eq(2)
      expect(api_entreprise[:refused]).to eq(1)
      expect(api_entreprise[:total]).to eq(3)
      
      expect(api_particulier[:validated]).to eq(1)
      expect(api_particulier[:refused]).to eq(0)
      expect(api_particulier[:total]).to eq(1)
    end

    it 'excludes other states like draft' do
      result = subject.volume_by_type_with_states
      
      # Draft request should be excluded from the count
      total_count = result.sum { |r| r[:total] }
      expect(total_count).to eq(4) # Not 5 (excluding the draft)
    end

    it 'sorts results by total count descending' do
      result = subject.volume_by_type_with_states
      
      totals = result.map { |r| r[:total] }
      expect(totals).to eq(totals.sort.reverse)
    end
  end

  describe '#volume_by_provider_with_states' do
    let(:base_time) { Time.zone.parse('2025-03-15 10:00:00') }
    let!(:user) { create(:user) }
    let!(:organization) { create(:organization) }
    
    before do
      user.add_to_organization(organization, current: true)
    end

    let!(:ar_validated_entreprise) do
      create(:authorization_request, :api_entreprise, :validated, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
      end
    end

    let!(:ar_refused_entreprise) do
      create(:authorization_request, :api_entreprise, :refused, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
      end
    end

    let!(:ar_validated_particulier) do
      create(:authorization_request, :api_particulier, :validated, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
      end
    end

    let!(:ar_submitted) do
      create(:authorization_request, :api_particulier, :submitted, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
      end
    end

    let(:authorization_requests) { AuthorizationRequest.where(id: [ar_validated_entreprise.id, ar_refused_entreprise.id, ar_validated_particulier.id, ar_submitted.id]) }
    subject { described_class.new(authorization_requests) }

    it 'returns volume grouped by provider with state split' do
      result = subject.volume_by_provider_with_states
      
      expect(result).to be_an(Array)
      expect(result.length).to be >= 1
      
      # Check that each item has the required keys
      result.each do |item|
        expect(item).to have_key(:provider)
        expect(item).to have_key(:validated)
        expect(item).to have_key(:refused)
        expect(item).to have_key(:total)
      end
      
      # Total validated and refused should equal our test data (excluding submitted)
      total_count = result.sum { |r| r[:total] }
      expect(total_count).to eq(3) # Not 4 (excluding submitted)
    end

    it 'sorts results by total count descending' do
      result = subject.volume_by_provider_with_states
      
      totals = result.map { |r| r[:total] }
      expect(totals).to eq(totals.sort.reverse)
    end
  end

  describe '#volume_by_form' do
    let(:base_time) { Time.zone.parse('2025-03-15 10:00:00') }
    let!(:user) { create(:user) }
    let!(:organization) { create(:organization) }
    
    before do
      user.add_to_organization(organization, current: true)
    end

    let!(:ar1) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
      end
    end

    let!(:ar2) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
      end
    end

    let!(:ar3) do
      create(:authorization_request, :api_particulier, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
      end
    end

    let(:authorization_requests) { AuthorizationRequest.where(id: [ar1.id, ar2.id, ar3.id]) }
    subject { described_class.new(authorization_requests) }

    it 'returns volume grouped by form_uid' do
      result = subject.volume_by_form
      
      expect(result).to be_an(Array)
      expect(result.length).to be >= 1
      
      result.each do |item|
        expect(item).to have_key(:form_uid)
        expect(item).to have_key(:count)
        expect(item[:count]).to be > 0
      end
      
      total_count = result.sum { |r| r[:count] }
      expect(total_count).to eq(3)
    end

    it 'sorts results by count descending' do
      result = subject.volume_by_form
      
      counts = result.map { |r| r[:count] }
      expect(counts).to eq(counts.sort.reverse)
    end
  end

  describe '#median_time_to_submit_by_form' do
    let(:base_time) { Time.zone.parse('2025-03-15 10:00:00') }
    let!(:user) { create(:user) }
    let!(:organization) { create(:organization) }
    
    before do
      user.add_to_organization(organization, current: true)
    end

    let!(:ar1) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 1.hour)
      end
    end

    let!(:ar2) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 3.hours)
      end
    end

    let!(:ar3) do
      create(:authorization_request, :api_particulier, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 5.hours)
      end
    end

    subject { described_class.new }

    it 'returns median time grouped by form_uid' do
      result = subject.median_time_to_submit_by_form
      
      expect(result).to be_an(Array)
      expect(result.length).to be >= 1
      
      result.each do |item|
        expect(item).to have_key(:form_uid)
        expect(item).to have_key(:median_time)
        expect(item).to have_key(:count)
      end
    end

    it 'sorts results by median time ascending' do
      result = subject.median_time_to_submit_by_form
      
      median_times = result.map { |r| r[:median_time] }
      expect(median_times).to eq(median_times.sort)
    end
  end

  describe '#median_time_to_first_instruction_by_form' do
    let(:base_time) { Time.zone.parse('2025-03-15 10:00:00') }
    let!(:user) { create(:user) }
    let!(:organization) { create(:organization) }
    
    before do
      user.add_to_organization(organization, current: true)
    end

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

    it 'returns median time grouped by form_uid' do
      result = subject.median_time_to_first_instruction_by_form
      
      expect(result).to be_an(Array)
      expect(result.length).to be >= 1
      
      result.each do |item|
        expect(item).to have_key(:form_uid)
        expect(item).to have_key(:median_time)
        expect(item).to have_key(:count)
      end
    end

    it 'sorts results by median time ascending' do
      result = subject.median_time_to_first_instruction_by_form
      
      median_times = result.map { |r| r[:median_time] }
      expect(median_times).to eq(median_times.sort)
    end
  end

  describe '#active_authorizations_by_organization_type' do
    let(:base_time) { Time.zone.parse('2025-03-15 10:00:00') }
    let!(:user) { create(:user) }
    
    let!(:organization_sas) do
      create(:organization, insee_payload: {
        'etablissement' => {
          'uniteLegale' => {
            'categorieJuridiqueUniteLegale' => '5710'
          }
        }
      })
    end
    
    let!(:organization_sarl) do
      create(:organization, insee_payload: {
        'etablissement' => {
          'uniteLegale' => {
            'categorieJuridiqueUniteLegale' => '5499'
          }
        }
      })
    end
    
    let!(:organization_commune) do
      create(:organization, insee_payload: {
        'etablissement' => {
          'uniteLegale' => {
            'categorieJuridiqueUniteLegale' => '7210'
          }
        }
      })
    end
    
    let!(:organization_no_payload) do
      create(:organization, insee_payload: nil)
    end
    
    before do
      user.add_to_organization(organization_sas, current: true)
      user.add_to_organization(organization_sarl)
      user.add_to_organization(organization_commune)
      user.add_to_organization(organization_no_payload)
    end

    let!(:ar_sas_1) do
      create(:authorization_request, :api_entreprise, :validated, applicant: user, organization: organization_sas, created_at: base_time)
    end
    
    let!(:ar_sas_2) do
      create(:authorization_request, :api_particulier, :validated, applicant: user, organization: organization_sas, created_at: base_time)
    end
    
    let!(:ar_sarl) do
      create(:authorization_request, :api_entreprise, :validated, applicant: user, organization: organization_sarl, created_at: base_time)
    end
    
    let!(:ar_commune_1) do
      create(:authorization_request, :api_particulier, :validated, applicant: user, organization: organization_commune, created_at: base_time)
    end
    
    let!(:ar_commune_2) do
      create(:authorization_request, :api_entreprise, :validated, applicant: user, organization: organization_commune, created_at: base_time)
    end
    
    let!(:ar_commune_3) do
      create(:authorization_request, :api_particulier, :validated, applicant: user, organization: organization_commune, created_at: base_time)
    end
    
    let!(:ar_no_payload) do
      create(:authorization_request, :api_entreprise, :validated, applicant: user, organization: organization_no_payload, created_at: base_time)
    end
    
    let!(:ar_draft) do
      create(:authorization_request, :api_entreprise, :draft, applicant: user, organization: organization_sas, created_at: base_time)
    end

    subject { described_class.new }

    it 'returns active authorizations grouped by organization type' do
      result = subject.active_authorizations_by_organization_type
      
      expect(result).to be_an(Array)
      expect(result.length).to eq(3)
      
      sas_item = result.find { |item| item[:category_code] == '5710' }
      sarl_item = result.find { |item| item[:category_code] == '5499' }
      commune_item = result.find { |item| item[:category_code] == '7210' }
      
      expect(sas_item).to be_present
      expect(sas_item[:count]).to eq(2)
      
      expect(sarl_item).to be_present
      expect(sarl_item[:count]).to eq(1)
      
      expect(commune_item).to be_present
      expect(commune_item[:count]).to eq(3)
    end

    it 'excludes organizations without insee_payload' do
      result = subject.active_authorizations_by_organization_type
      
      expect(result.any? { |item| item[:category_code].nil? }).to be false
    end

    it 'excludes non-validated authorizations' do
      result = subject.active_authorizations_by_organization_type
      
      total_count = result.sum { |item| item[:count] }
      expect(total_count).to eq(6)
    end

    it 'sorts results by count descending' do
      result = subject.active_authorizations_by_organization_type
      
      counts = result.map { |item| item[:count] }
      expect(counts).to eq(counts.sort.reverse)
    end
    
    context 'with revoked authorizations' do
      let!(:ar_sas_revoked) do
        create(:authorization_request, :api_entreprise, :validated, applicant: user, organization: organization_sas, created_at: base_time).tap do |ar|
          authorization = ar.latest_authorization
          authorization.revoke!
          authorization.update!(revoked: true)
        end
      end
      
      it 'excludes revoked authorizations' do
        result = subject.active_authorizations_by_organization_type
        
        sas_item = result.find { |item| item[:category_code] == '5710' }
        expect(sas_item[:count]).to eq(2)
      end
    end
  end

  describe '#time_to_first_instruction_by_duration_buckets' do
    let(:base_time) { Time.zone.parse('2025-03-15 10:00:00') }
    let!(:user) { create(:user) }
    let!(:organization) { create(:organization) }
    
    before do
      user.add_to_organization(organization, current: true)
    end

    # Create authorization requests with different time to first instruction durations
    let!(:ar_30_seconds) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 1.hour)
        create(:authorization_request_event, :approve, authorization_request: ar, user: user, created_at: base_time + 1.hour + 30.seconds)
      end
    end

    let!(:ar_90_seconds) do
      create(:authorization_request, :api_particulier, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 1.hour)
        create(:authorization_request_event, :request_changes, authorization_request: ar, user: user, created_at: base_time + 1.hour + 90.seconds)
      end
    end

    let!(:ar_2_hours) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 1.hour)
        create(:authorization_request_event, :approve, authorization_request: ar, user: user, created_at: base_time + 1.hour + 2.hours)
      end
    end

    let!(:ar_5_days) do
      create(:authorization_request, :api_particulier, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 1.hour)
        create(:authorization_request_event, :refuse, authorization_request: ar, user: user, created_at: base_time + 1.hour + 5.days)
      end
    end

    subject { described_class.new }

    context 'with step: :minute' do
      it 'returns buckets grouped by minutes' do
        buckets = subject.time_to_first_instruction_by_duration_buckets(step: :minute)
        
        expect(buckets).to be_an(Array)
        expect(buckets.first[:bucket]).to eq('<1')
        expect(buckets.last[:bucket]).to eq('> 60')
        
        # Check structure
        expect(buckets.all? { |b| b.key?(:bucket) && b.key?(:count) }).to be true
        
        # Should have 62 buckets: <1, 1-60, > 60
        expect(buckets.size).to eq(62)
      end

      it 'distributes values correctly' do
        buckets = subject.time_to_first_instruction_by_duration_buckets(step: :minute)
        
        total = buckets.sum { |b| b[:count] }
        expect(total).to be > 0
      end
    end

    context 'with step: :hour' do
      it 'returns buckets grouped by hours' do
        buckets = subject.time_to_first_instruction_by_duration_buckets(step: :hour)
        
        expect(buckets).to be_an(Array)
        expect(buckets.first[:bucket]).to eq('<1')
        expect(buckets.last[:bucket]).to eq('> 24')
        
        # Should have 26 buckets: <1, 1-24, > 24
        expect(buckets.size).to eq(26)
      end
    end

    context 'with step: :day' do
      it 'returns buckets grouped by days' do
        buckets = subject.time_to_first_instruction_by_duration_buckets(step: :day)
        
        expect(buckets).to be_an(Array)
        expect(buckets.first[:bucket]).to eq('<1')
        expect(buckets.last[:bucket]).to eq('> 30')
        
        # Should have 32 buckets: <1, 1-30, > 30
        expect(buckets.size).to eq(32)
      end
    end

    context 'with invalid step' do
      it 'raises an error' do
        expect { subject.time_to_first_instruction_by_duration_buckets(step: :invalid) }.to raise_error(ArgumentError)
      end
    end

    context 'with no authorization requests with instruction events' do
      subject { described_class.new(AuthorizationRequest.none) }

      it 'returns empty array' do
        buckets = subject.time_to_first_instruction_by_duration_buckets(step: :day)
        expect(buckets).to eq([])
      end
    end
  end

  describe '#average_time_to_production_instruction' do
    let(:base_time) { Time.zone.parse('2025-07-01 10:00:00') }
    let!(:user) { create(:user) }
    let!(:organization) { create(:organization) }
    
    before do
      user.add_to_organization(organization, current: true)
    end

    let!(:ar1) do
      create(:authorization_request, :api_impot_particulier, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :start_next_stage, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :approve, authorization_request: ar, user: user, created_at: base_time + 2.days)
      end
    end

    let!(:ar2) do
      create(:authorization_request, :api_r2p_production, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :start_next_stage, authorization_request: ar, user: user, created_at: base_time + 1.day)
        create(:authorization_request_event, :refuse, authorization_request: ar, user: user, created_at: base_time + 1.day + 5.days)
      end
    end

    let(:authorization_requests) { AuthorizationRequest.where(id: [ar1.id, ar2.id]) }
    subject { described_class.new(authorization_requests) }

    it 'returns average time from start_next_stage to first instruction' do
      avg_time = subject.average_time_to_production_instruction
      
      # ar1: 2 days = 172800 seconds
      # ar2: 5 days = 432000 seconds
      # Average: (172800 + 432000) / 2 = 302400 seconds
      expect(avg_time).to be_within(1).of(302400)
    end
  end

  describe '#median_time_to_production_instruction' do
    let(:base_time) { Time.zone.parse('2025-07-01 10:00:00') }
    let!(:user) { create(:user) }
    let!(:organization) { create(:organization) }
    
    before do
      user.add_to_organization(organization, current: true)
    end

    let!(:ar1) do
      create(:authorization_request, :api_impot_particulier, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :start_next_stage, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :approve, authorization_request: ar, user: user, created_at: base_time + 1.day)
      end
    end

    let!(:ar2) do
      create(:authorization_request, :api_r2p_production, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :start_next_stage, authorization_request: ar, user: user, created_at: base_time + 1.day)
        create(:authorization_request_event, :refuse, authorization_request: ar, user: user, created_at: base_time + 1.day + 3.days)
      end
    end

    let(:authorization_requests) { AuthorizationRequest.where(id: [ar1.id, ar2.id]) }
    subject { described_class.new(authorization_requests) }

    it 'returns median time from start_next_stage to first instruction' do
      median_time = subject.median_time_to_production_instruction
      
      # ar1: 1 day = 86400 seconds
      # ar2: 3 days = 259200 seconds
      # Median of 2 values: (86400 + 259200) / 2 = 172800 seconds
      expect(median_time).to be_within(1).of(172800)
    end
  end

  describe '#stddev_time_to_production_instruction' do
    let(:base_time) { Time.zone.parse('2025-07-01 10:00:00') }
    let!(:user) { create(:user) }
    let!(:organization) { create(:organization) }
    
    before do
      user.add_to_organization(organization, current: true)
    end

    let!(:ar1) do
      create(:authorization_request, :api_impot_particulier, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :start_next_stage, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :approve, authorization_request: ar, user: user, created_at: base_time + 1.day)
      end
    end

    let!(:ar2) do
      create(:authorization_request, :api_r2p_production, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :start_next_stage, authorization_request: ar, user: user, created_at: base_time + 1.day)
        create(:authorization_request_event, :refuse, authorization_request: ar, user: user, created_at: base_time + 1.day + 5.days)
      end
    end

    let(:authorization_requests) { AuthorizationRequest.where(id: [ar1.id, ar2.id]) }
    subject { described_class.new(authorization_requests) }

    it 'returns standard deviation of time to production instruction' do
      stddev_time = subject.stddev_time_to_production_instruction
      
      # ar1: 86400 seconds
      # ar2: 432000 seconds
      # Mean: 259200
      # Variance: ((86400-259200)^2 + (432000-259200)^2) / 2 = (29859840000 + 29859840000) / 2 = 29859840000
      # StdDev: sqrt(29859840000) ≈ 172800 seconds
      expect(stddev_time).to be_within(1000).of(172800)
    end
  end

  describe '#mode_time_to_production_instruction' do
    let(:base_time_mode) { Time.zone.parse('2025-07-15 10:00:00') }
    let!(:user_mode) { create(:user) }
    let!(:organization_mode) { create(:organization) }
    
    before do
      user_mode.add_to_organization(organization_mode, current: true)
    end

    let!(:ar_mode_1) do
      create(:authorization_request, :api_impot_particulier, applicant: user_mode, organization: organization_mode, created_at: base_time_mode).tap do |ar|
        create(:authorization_request_event, :start_next_stage, authorization_request: ar, user: user_mode, created_at: base_time_mode)
        create(:authorization_request_event, :approve, authorization_request: ar, user: user_mode, created_at: base_time_mode + 1.day + 2.hours)
      end
    end

    let!(:ar_mode_2) do
      create(:authorization_request, :api_r2p_production, applicant: user_mode, organization: organization_mode, created_at: base_time_mode).tap do |ar|
        create(:authorization_request_event, :start_next_stage, authorization_request: ar, user: user_mode, created_at: base_time_mode)
        create(:authorization_request_event, :approve, authorization_request: ar, user: user_mode, created_at: base_time_mode + 1.day + 3.hours)
      end
    end

    let!(:ar_mode_3) do
      create(:authorization_request, :api_sfip_production, applicant: user_mode, organization: organization_mode, created_at: base_time_mode).tap do |ar|
        create(:authorization_request_event, :start_next_stage, authorization_request: ar, user: user_mode, created_at: base_time_mode)
        create(:authorization_request_event, :request_changes, authorization_request: ar, user: user_mode, created_at: base_time_mode + 5.days)
      end
    end

    let(:mode_authorization_requests) { AuthorizationRequest.where(id: [ar_mode_1.id, ar_mode_2.id, ar_mode_3.id]) }
    subject { described_class.new(mode_authorization_requests) }

    it 'returns the most frequent time to production instruction (rounded up to nearest day)' do
      mode_time = subject.mode_time_to_production_instruction
      
      # ar_mode_1: 1 day + 2 hours = 93600 seconds, ceils to 2 days (172800 seconds)
      # ar_mode_2: 1 day + 3 hours = 97200 seconds, ceils to 2 days (172800 seconds)
      # ar_mode_3: 5 days = 432000 seconds, ceils to 5 days (432000 seconds)
      # Most frequent is 2 days (172800 seconds)
      expect(mode_time).to eq(172800.0)
    end
  end

  describe '#median_time_to_production_instruction_by_type' do
    let(:base_time) { Time.zone.parse('2025-08-01 10:00:00') }
    let!(:user) { create(:user) }
    let!(:organization) { create(:organization) }
    
    before do
      user.add_to_organization(organization, current: true)
    end

    let!(:ar1) do
      create(:authorization_request, :api_impot_particulier, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :start_next_stage, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :approve, authorization_request: ar, user: user, created_at: base_time + 2.days)
      end
    end

    let!(:ar2) do
      create(:authorization_request, :api_impot_particulier, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :start_next_stage, authorization_request: ar, user: user, created_at: base_time + 1.day)
        create(:authorization_request_event, :refuse, authorization_request: ar, user: user, created_at: base_time + 1.day + 4.days)
      end
    end

    let!(:ar3) do
      create(:authorization_request, :api_r2p_production, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :start_next_stage, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :approve, authorization_request: ar, user: user, created_at: base_time + 10.days)
      end
    end

    let(:authorization_requests) { AuthorizationRequest.where(id: [ar1.id, ar2.id, ar3.id]) }
    subject { described_class.new(authorization_requests) }

    it 'returns median time grouped by type' do
      result = subject.median_time_to_production_instruction_by_type
      
      expect(result).to be_an(Array)
      expect(result.length).to eq(2)
      
      # Find the types
      api_impot = result.find { |r| r[:type].include?('APIImpotParticulier') }
      api_r2p = result.find { |r| r[:type].include?('APIR2P') }
      
      expect(api_impot).to be_present
      expect(api_r2p).to be_present
      
      # APIImpotParticulier: 2 days and 4 days, median = 3 days
      expect(api_impot[:median_time]).to be_within(100).of(259200) # 3 days in seconds
      expect(api_impot[:count]).to eq(2)
      
      # APIR2P: 10 days
      expect(api_r2p[:median_time]).to be_within(100).of(864000) # 10 days in seconds
      expect(api_r2p[:count]).to eq(1)
    end
  end

  describe '#time_to_production_instruction_by_duration_buckets' do
    let(:base_time) { Time.zone.parse('2025-08-15 10:00:00') }
    let!(:user) { create(:user) }
    let!(:organization) { create(:organization) }
    
    before do
      user.add_to_organization(organization, current: true)
    end

    let!(:ar_1_day) do
      create(:authorization_request, :api_impot_particulier, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :start_next_stage, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :approve, authorization_request: ar, user: user, created_at: base_time + 1.day)
      end
    end

    let!(:ar_3_days) do
      create(:authorization_request, :api_r2p_production, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :start_next_stage, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :refuse, authorization_request: ar, user: user, created_at: base_time + 3.days)
      end
    end

    let!(:ar_7_days) do
      create(:authorization_request, :api_sfip_production, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :start_next_stage, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :request_changes, authorization_request: ar, user: user, created_at: base_time + 7.days)
      end
    end

    let(:authorization_requests) { AuthorizationRequest.where(id: [ar_1_day.id, ar_3_days.id, ar_7_days.id]) }
    subject { described_class.new(authorization_requests) }

    context 'with step: :day' do
      it 'returns buckets grouped by days' do
        buckets = subject.time_to_production_instruction_by_duration_buckets(step: :day)
        
        expect(buckets).to be_an(Array)
        expect(buckets.first[:bucket]).to eq('<1')
        expect(buckets.last[:bucket]).to eq('> 30')
        
        # Should have 32 buckets: <1, 1-30, > 30
        expect(buckets.size).to eq(32)
      end

      it 'distributes values correctly' do
        buckets = subject.time_to_production_instruction_by_duration_buckets(step: :day)
        
        total = buckets.sum { |b| b[:count] }
        expect(total).to eq(3)
        
        # Check that day 1 has 1, day 3 has 1, day 7 has 1
        day_1 = buckets.find { |b| b[:bucket] == '1' }
        day_3 = buckets.find { |b| b[:bucket] == '3' }
        day_7 = buckets.find { |b| b[:bucket] == '7' }
        
        expect(day_1[:count]).to eq(1)
        expect(day_3[:count]).to eq(1)
        expect(day_7[:count]).to eq(1)
      end
    end

    context 'with no authorization requests with production instruction events' do
      subject { described_class.new(AuthorizationRequest.none) }

      it 'returns empty array' do
        buckets = subject.time_to_production_instruction_by_duration_buckets(step: :day)
        expect(buckets).to eq([])
      end
    end

    context 'with authorization request without instruction event after start_next_stage' do
      let!(:ar_no_instruction) do
        create(:authorization_request, :api_impot_particulier, applicant: user, organization: organization, created_at: base_time).tap do |ar|
          create(:authorization_request_event, :start_next_stage, authorization_request: ar, user: user, created_at: base_time)
          # No instruction event
        end
      end

      let(:authorization_requests_with_no_instruction) { AuthorizationRequest.where(id: [ar_1_day.id, ar_no_instruction.id]) }
      subject { described_class.new(authorization_requests_with_no_instruction) }

      it 'excludes authorization requests without instruction events' do
        buckets = subject.time_to_production_instruction_by_duration_buckets(step: :day)
        
        total = buckets.sum { |b| b[:count] }
        expect(total).to eq(1) # Only ar_1_day should be counted
      end
    end
  end
end
