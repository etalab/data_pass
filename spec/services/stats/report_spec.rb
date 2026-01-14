RSpec.describe Stats::Report, type: :service do
  describe '#initialize' do
    context 'with a year as date_input' do
      subject { described_class.new(date_input: 2025) }

      it 'initializes with a full year range' do
        expect(subject.instance_variable_get(:@date_range)).to eq(Date.new(2025).all_year)
      end
    end

    context 'with a date range' do
      let(:start_date) { Date.new(2025, 1, 1) }
      let(:end_date) { Date.new(2025, 3, 31) }

      subject { described_class.new(date_input: start_date..end_date) }

      it 'initializes with the provided range' do
        expect(subject.instance_variable_get(:@date_range)).to eq(start_date..end_date)
      end
    end

    context 'with invalid date_input' do
      it 'raises an error' do
        expect { described_class.new(date_input: 'invalid') }.to raise_error('Invalid date range: invalid')
      end
    end

    context 'with authorization_types filter' do
      subject { described_class.new(date_input: 2025, authorization_types: ['AuthorizationRequest::APIEntreprise']) }

      it 'stores the authorization types' do
        expect(subject.instance_variable_get(:@authorization_types)).to eq(['AuthorizationRequest::APIEntreprise'])
      end
    end

    context 'without authorization_types filter' do
      subject { described_class.new(date_input: 2025) }

      it 'authorization_types is nil' do
        expect(subject.instance_variable_get(:@authorization_types)).to be_nil
      end
    end

    context 'with provider filter' do
      let!(:data_provider) { create(:data_provider, slug: 'test-provider', name: 'Test Provider') }
      
      before do
        allow(DataProvider).to receive(:friendly).and_return(DataProvider)
        allow(DataProvider).to receive(:find).with('test-provider').and_return(data_provider)
        
        # Mock authorization definitions for the provider
        api_entreprise_def = instance_double(AuthorizationDefinition, authorization_request_class_as_string: 'AuthorizationRequest::APIEntreprise')
        api_particulier_def = instance_double(AuthorizationDefinition, authorization_request_class_as_string: 'AuthorizationRequest::APIParticulier')
        
        allow(data_provider).to receive(:authorization_definitions).and_return([api_entreprise_def, api_particulier_def])
      end

      subject { described_class.new(date_input: 2025, provider: 'test-provider') }

      it 'automatically sets authorization_types from provider' do
        types = subject.instance_variable_get(:@authorization_types)
        expect(types).to include('AuthorizationRequest::APIEntreprise', 'AuthorizationRequest::APIParticulier')
      end

      it 'stores the provider slug' do
        expect(subject.instance_variable_get(:@provider)).to eq('test-provider')
      end
    end

    context 'with invalid provider' do
      before do
        allow(DataProvider).to receive(:friendly).and_return(DataProvider)
        allow(DataProvider).to receive(:find).with('invalid-provider').and_raise(ActiveRecord::RecordNotFound)
      end

      it 'raises an error' do
        expect { described_class.new(date_input: 2025, provider: 'invalid-provider') }.to raise_error('Provider not found: invalid-provider')
      end
    end
  end

  describe '#print_report' do
    let(:base_time) { Time.zone.parse('2025-03-15 10:00:00') }
    let!(:user) { create(:user) }
    let!(:organization) { create(:organization) }
    
    before do
      user.add_to_organization(organization, current: true)
    end

    # Create authorization requests within 2025
    let!(:ar1) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 1.hour)
      end
    end

    let!(:ar2) do
      create(:authorization_request, :api_particulier, applicant: user, organization: organization, created_at: base_time + 1.day).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time + 1.day)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 1.day + 3.hours)
      end
    end

    subject { described_class.new(date_input: 2025) }

    it 'prints the report without error' do
      expect { subject.print_report }.to output(/# Report of/).to_stdout
      expect { subject.print_report }.to output(/authorization requests created/).to_stdout
      expect { subject.print_report }.to output(/reopen events/).to_stdout
      expect { subject.print_report }.to output(/Average time to submit/).to_stdout
      expect { subject.print_report }.to output(/Median time to submit/).to_stdout
      expect { subject.print_report }.to output(/Standard deviation time to submit/).to_stdout
      expect { subject.print_report }.to output(/Average time to first instruction/).to_stdout
      expect { subject.print_report }.to output(/Median time to first instruction/).to_stdout
      expect { subject.print_report }.to output(/Standard deviation time to first instruction/).to_stdout
    end
  end

  describe '#average_time_to_submit' do
    subject { described_class.new(date_input: 2025).average_time_to_submit }

    let(:base_time) { Time.zone.parse('2025-06-01 10:00:00') }
    
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }
    let!(:organization1) { create(:organization) }
    let!(:organization2) { create(:organization) }
    
    before do
      user1.add_to_organization(organization1, current: true)
      user2.add_to_organization(organization2, current: true)
    end

    # Create 15 authorization requests in 2025 with varied submission times
    let!(:ar1) do
      create(:authorization_request, :api_entreprise, applicant: user1, organization: organization1, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user1, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user1, created_at: base_time + 2.hours)
      end
    end

    let!(:ar2) do
      create(:authorization_request, :api_particulier, applicant: user1, organization: organization1, created_at: base_time + 1.day).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user1, created_at: base_time + 1.day)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user1, created_at: base_time + 1.day + 5.hours)
      end
    end

    let!(:ar3) do
      create(:authorization_request, :france_connect, applicant: user2, organization: organization2, created_at: base_time + 2.days).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user2, created_at: base_time + 2.days)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user2, created_at: base_time + 2.days + 1.day)
      end
    end

    let!(:ar4) do
      create(:authorization_request, :api_entreprise, applicant: user1, organization: organization1, created_at: base_time + 3.days).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user1, created_at: base_time + 3.days)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user1, created_at: base_time + 3.days + 30.minutes)
      end
    end

    let!(:ar5) do
      create(:authorization_request, :hubee_cert_dc, applicant: user2, organization: organization2, created_at: base_time + 4.days).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user2, created_at: base_time + 4.days)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user2, created_at: base_time + 4.days + 10.hours)
      end
    end

    let!(:ar6) do
      create(:authorization_request, :api_particulier, applicant: user1, organization: organization1, created_at: base_time + 5.days).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user1, created_at: base_time + 5.days)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user1, created_at: base_time + 5.days + 3.days)
      end
    end

    let!(:ar7) do
      create(:authorization_request, :api_captchetat, applicant: user2, organization: organization2, created_at: base_time + 6.days).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user2, created_at: base_time + 6.days)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user2, created_at: base_time + 6.days + 6.hours)
      end
    end

    let!(:ar8) do
      create(:authorization_request, :hubee_dila, applicant: user1, organization: organization1, created_at: base_time + 7.days).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user1, created_at: base_time + 7.days)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user1, created_at: base_time + 7.days + 15.hours)
      end
    end

    let!(:ar9) do
      create(:authorization_request, :api_entreprise, applicant: user2, organization: organization2, created_at: base_time + 8.days).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user2, created_at: base_time + 8.days)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user2, created_at: base_time + 8.days + 2.days)
      end
    end

    let!(:ar10) do
      create(:authorization_request, :api_particulier, applicant: user1, organization: organization1, created_at: base_time + 9.days).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user1, created_at: base_time + 9.days)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user1, created_at: base_time + 9.days + 8.hours)
      end
    end

    let!(:ar11) do
      create(:authorization_request, :france_connect, applicant: user2, organization: organization2, created_at: base_time + 10.days).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user2, created_at: base_time + 10.days)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user2, created_at: base_time + 10.days + 12.hours)
      end
    end

    let!(:ar12) do
      create(:authorization_request, :api_entreprise, applicant: user1, organization: organization1, created_at: base_time + 11.days).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user1, created_at: base_time + 11.days)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user1, created_at: base_time + 11.days + 4.hours)
      end
    end

    let!(:ar13) do
      create(:authorization_request, :api_particulier, applicant: user2, organization: organization2, created_at: base_time + 12.days).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user2, created_at: base_time + 12.days)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user2, created_at: base_time + 12.days + 18.hours)
      end
    end

    let!(:ar14) do
      create(:authorization_request, :hubee_cert_dc, applicant: user1, organization: organization1, created_at: base_time + 13.days).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user1, created_at: base_time + 13.days)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user1, created_at: base_time + 13.days + 5.days)
      end
    end

    let!(:ar15) do
      create(:authorization_request, :api_captchetat, applicant: user2, organization: organization2, created_at: base_time + 14.days).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user2, created_at: base_time + 14.days)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user2, created_at: base_time + 14.days + 1.hour)
      end
    end

    # Request created in 2024 - should be excluded
    let!(:ar_2024) do
      create(:authorization_request, :api_entreprise, applicant: user1, organization: organization1, created_at: Time.zone.parse('2024-12-31 23:00:00')).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user1, created_at: Time.zone.parse('2024-12-31 23:00:00'))
        create(:authorization_request_event, :submit, authorization_request: ar, user: user1, created_at: Time.zone.parse('2024-12-31 23:30:00'))
      end
    end

    # Request created in 2026 - should be excluded
    let!(:ar_2026) do
      create(:authorization_request, :api_particulier, applicant: user1, organization: organization1, created_at: Time.zone.parse('2026-01-01 01:00:00')).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user1, created_at: Time.zone.parse('2026-01-01 01:00:00'))
        create(:authorization_request_event, :submit, authorization_request: ar, user: user1, created_at: Time.zone.parse('2026-01-01 01:30:00'))
      end
    end

    it 'returns a formatted string with the average time' do
      expect(subject).to match(/Average time to submit: .+/)
      expect(subject).not_to include('N/A')
    end

    it 'only includes authorization requests created in 2025' do
      # Should include 15 requests (ar1-ar15), exclude ar_2024 and ar_2026
      report = described_class.new(date_input: 2025)
      count = report.instance_variable_get(:@authorization_requests_created_in_range).count
      expect(count).to eq(15)
    end
  end

  describe '#median_time_to_submit' do
    subject { described_class.new(date_input: 2025).median_time_to_submit }

    let(:base_time) { Time.zone.parse('2025-08-01 12:00:00') }
    let!(:user) { create(:user) }
    let!(:organization) { create(:organization) }
    
    before do
      user.add_to_organization(organization, current: true)
    end

    let!(:ar_very_fast) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 5.minutes)
      end
    end

    let!(:ar_medium) do
      create(:authorization_request, :api_particulier, applicant: user, organization: organization, created_at: base_time + 1.day).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time + 1.day)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 1.day + 3.hours)
      end
    end

    let!(:ar_slow) do
      create(:authorization_request, :france_connect, applicant: user, organization: organization, created_at: base_time + 2.days).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time + 2.days)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 2.days + 7.days)
      end
    end

    it 'returns a formatted string with the median time' do
      expect(subject).to match(/Median time to submit: .+/)
      expect(subject).to match(/3 (hours|heures)/)
    end
  end

  describe '#stddev_time_to_submit' do
    subject { described_class.new(date_input: 2025).stddev_time_to_submit }

    let(:base_time) { Time.zone.parse('2025-09-01 14:00:00') }
    let!(:user) { create(:user) }
    let!(:organization) { create(:organization) }
    
    before do
      user.add_to_organization(organization, current: true)
    end

    let!(:ar_fast) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 10.minutes)
      end
    end

    let!(:ar_medium) do
      create(:authorization_request, :api_particulier, applicant: user, organization: organization, created_at: base_time + 1.day).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time + 1.day)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 1.day + 4.hours)
      end
    end

    let!(:ar_very_slow) do
      create(:authorization_request, :hubee_cert_dc, applicant: user, organization: organization, created_at: base_time + 2.days).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time + 2.days)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 2.days + 21.days)
      end
    end

    it 'returns a formatted string with the standard deviation' do
      expect(subject).to match(/Standard deviation time to submit: .+/)
    end
  end

  describe '#average_time_to_first_instruction' do
    subject { described_class.new(date_input: 2025).average_time_to_first_instruction }

    let(:base_time) { Time.zone.parse('2025-09-01 14:00:00') }
    let!(:user) { create(:user) }
    let!(:organization) { create(:organization) }
    
    before do
      user.add_to_organization(organization, current: true)
    end

    let!(:ar_fast_instruction) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 1.hour)
        create(:authorization_request_event, :approve, authorization_request: ar, user: user, created_at: base_time + 1.hour + 2.hours)
      end
    end

    let!(:ar_slow_instruction) do
      create(:authorization_request, :api_particulier, applicant: user, organization: organization, created_at: base_time + 1.day).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time + 1.day)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 1.day + 3.hours)
        create(:authorization_request_event, :request_changes, authorization_request: ar, user: user, created_at: base_time + 1.day + 3.hours + 5.days)
      end
    end

    it 'returns a formatted string with the average time' do
      expect(subject).to match(/Average time to first instruction: .+/)
    end
  end

  describe '#stddev_time_to_first_instruction' do
    subject { described_class.new(date_input: 2025).stddev_time_to_first_instruction }

    let(:base_time) { Time.zone.parse('2025-09-01 14:00:00') }
    let!(:user) { create(:user) }
    let!(:organization) { create(:organization) }
    
    before do
      user.add_to_organization(organization, current: true)
    end

    let!(:ar_fast_instruction) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 1.hour)
        create(:authorization_request_event, :approve, authorization_request: ar, user: user, created_at: base_time + 1.hour + 2.hours)
      end
    end

    let!(:ar_very_slow_instruction) do
      create(:authorization_request, :hubee_cert_dc, applicant: user, organization: organization, created_at: base_time + 2.days).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time + 2.days)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 2.days + 1.hour)
        create(:authorization_request_event, :request_changes, authorization_request: ar, user: user, created_at: base_time + 2.days + 1.hour + 14.days)
      end
    end

    it 'returns a formatted string with the standard deviation' do
      expect(subject).to match(/Standard deviation time to first instruction: .+/)
    end
  end

  describe 'with custom date range' do
    let(:start_date) { Date.new(2025, 4, 1) }
    let(:end_date) { Date.new(2025, 6, 30) }
    let(:base_time_q2) { Time.zone.parse('2025-05-15 10:00:00') }
    
    subject { described_class.new(date_input: start_date..end_date) }

    let!(:user) { create(:user) }
    let!(:organization) { create(:organization) }
    
    before do
      user.add_to_organization(organization, current: true)
    end

    # Request in Q2 2025 (should be included)
    let!(:ar_q2) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: base_time_q2).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time_q2)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time_q2 + 3.hours)
      end
    end

    # Request in Q1 2025 (should be excluded)
    let!(:ar_q1) do
      create(:authorization_request, :api_particulier, applicant: user, organization: organization, created_at: Time.zone.parse('2025-03-15 10:00:00')).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Time.zone.parse('2025-03-15 10:00:00'))
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Time.zone.parse('2025-03-15 12:00:00'))
      end
    end

    # Request in Q3 2025 (should be excluded)
    let!(:ar_q3) do
      create(:authorization_request, :france_connect, applicant: user, organization: organization, created_at: Time.zone.parse('2025-07-15 10:00:00')).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: Time.zone.parse('2025-07-15 10:00:00'))
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: Time.zone.parse('2025-07-15 13:00:00'))
      end
    end

    it 'only includes authorization requests in the specified date range' do
      count = subject.instance_variable_get(:@authorization_requests_created_in_range).count
      expect(count).to eq(1)
    end

    it 'formats the date range as human readable' do
      expect { subject.print_report }.to output(/01\/04\/2025 - 30\/06\/2025/).to_stdout
    end
  end

  describe '#format_duration' do
    subject { described_class.new(date_input: 2025) }

    it 'formats nil as N/A' do
      expect(subject.send(:format_duration, nil)).to eq('N/A')
    end

    it 'formats seconds as human readable duration' do
      # 1 hour
      duration = subject.send(:format_duration, 3600)
      expect(duration).to match(/1 hour|about 1 hour|heure/)
    end

    it 'formats days correctly' do
      # 2 days
      duration = subject.send(:format_duration, 172800)
      expect(duration).to match(/2 (days|jours)/)
    end

    it 'formats minutes correctly' do
      # 30 minutes
      duration = subject.send(:format_duration, 1800)
      expect(duration).to include('30 minutes')
    end
  end

  describe 'edge cases' do
    context 'when no authorization requests exist in date range' do
      subject { described_class.new(date_input: 2020) }

      it 'returns N/A for all metrics' do
        expect(subject.average_time_to_submit).to include('N/A')
        expect(subject.median_time_to_submit).to include('N/A')
        expect(subject.stddev_time_to_submit).to include('N/A')
      end
    end

    context 'when authorization requests exist but none have submit events' do
      let!(:user) { create(:user) }
      let!(:organization) { create(:organization) }
      let(:base_time) { Time.zone.parse('2025-10-01 10:00:00') }
      
      before do
        user.add_to_organization(organization, current: true)
      end

      let!(:ar_draft_only) do
        create(:authorization_request, :api_entreprise, :draft, applicant: user, organization: organization, created_at: base_time).tap do |ar|
          create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        end
      end

      subject { described_class.new(date_input: 2025) }

      it 'returns N/A for all metrics' do
        expect(subject.average_time_to_submit).to include('N/A')
        expect(subject.median_time_to_submit).to include('N/A')
        expect(subject.stddev_time_to_submit).to include('N/A')
      end
    end
  end

  describe 'report output format' do
    let(:base_time) { Time.zone.parse('2025-11-01 09:00:00') }
    let!(:user) { create(:user) }
    let!(:organization) { create(:organization) }
    
    before do
      user.add_to_organization(organization, current: true)
    end

    let!(:sample_request) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 2.hours)
      end
    end

    subject { described_class.new(date_input: 2025) }

    it 'outputs a properly formatted report' do
      output = capture_stdout { subject.print_report }
      
      expect(output).to match(/# Report of/)
      expect(output).to match(/Average time to submit: .+/)
      expect(output).to match(/Median time to submit: .+/)
      expect(output).to match(/Standard deviation time to submit: .+/)
    end
  end

  describe '#time_to_submit_by_type_table' do
    let(:base_time) { Time.zone.parse('2025-12-01 10:00:00') }
    let!(:user) { create(:user) }
    let!(:organization) { create(:organization) }
    
    before do
      user.add_to_organization(organization, current: true)
    end

    let!(:api_entreprise_1) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 1.hour)
      end
    end

    let!(:api_entreprise_2) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: base_time + 1.day).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time + 1.day)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 1.day + 2.hours)
      end
    end

    let!(:api_particulier_1) do
      create(:authorization_request, :api_particulier, applicant: user, organization: organization, created_at: base_time + 2.days).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time + 2.days)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 2.days + 3.hours)
      end
    end

    subject { described_class.new(date_input: 2025) }

    it 'returns a formatted table' do
      table = subject.time_to_submit_by_type_table
      
      expect(table).to include('Type')
      expect(table).to include('Count')
      expect(table).to include('Min')
      expect(table).to include('Avg')
      expect(table).to include('Max')
    end

    it 'includes authorization request type names' do
      table = subject.time_to_submit_by_type_table
      
      expect(table).to match(/API\s*Entreprise/i)
      expect(table).to match(/API\s*Particulier/i)
    end

    it 'includes count information' do
      table = subject.time_to_submit_by_type_table
      
      # API Entreprise should have 2 requests
      lines = table.split("\n")
      api_entreprise_line = lines.find { |line| line.include?('Entreprise') }
      expect(api_entreprise_line).to match(/\|\s*2\s*\|/)
    end

    it 'formats durations as human readable' do
      table = subject.time_to_submit_by_type_table
      
      # Should include time-related words (in French or English)
      expect(table).to match(/hour|heure|minute/i)
    end
  end

  describe '#print_time_to_submit_by_type_table' do
    let(:base_time) { Time.zone.parse('2025-12-15 10:00:00') }
    let!(:user) { create(:user) }
    let!(:organization) { create(:organization) }
    
    before do
      user.add_to_organization(organization, current: true)
    end

    let!(:france_connect_1) do
      create(:authorization_request, :france_connect, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 45.minutes)
      end
    end

    subject { described_class.new(date_input: 2025) }

    it 'prints the table to stdout' do
      expect { subject.print_time_to_submit_by_type_table }.to output(/Time to submit by Authorization Request Type/).to_stdout
      expect { subject.print_time_to_submit_by_type_table }.to output(/Type/).to_stdout
      expect { subject.print_time_to_submit_by_type_table }.to output(/Count/).to_stdout
    end

    context 'with no data' do
      subject { described_class.new(date_input: 2020) }

      it 'prints a message when no data is available' do
        expect { subject.print_time_to_submit_by_type_table }.to output(/No data available/).to_stdout
      end
    end
  end

  describe '#number_of_authorization_requests_created' do
    let(:base_time) { Time.zone.parse('2025-12-25 10:00:00') }
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
      create(:authorization_request, :api_particulier, applicant: user, organization: organization, created_at: base_time + 1.day).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time + 1.day)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 1.day + 2.hours)
      end
    end

    let!(:ar3) do
      create(:authorization_request, :france_connect, applicant: user, organization: organization, created_at: base_time + 2.days).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time + 2.days)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 2.days + 30.minutes)
      end
    end

    subject { described_class.new(date_input: 2025) }

    it 'returns the count of authorization requests created in the date range' do
      expect(subject.number_of_authorization_requests_created).to eq('3 authorization requests created')
    end

    it 'includes the count in the report output' do
      expect { subject.print_report }.to output(/3 authorization requests created/).to_stdout
    end
  end

  describe '#number_of_reopen_events' do
    let(:base_time) { Time.zone.parse('2025-05-15 10:00:00') }
    let!(:user) { create(:user) }
    let!(:organization1) { create(:organization) }
    let!(:organization2) { create(:organization) }
    
    before do
      user.add_to_organization(organization1, current: true)
      user.add_to_organization(organization2)
    end

    let!(:ar1) do
      create(:authorization_request, :validated, applicant: user, organization: organization1, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 1.hour)
        create(:authorization_request_event, :reopen, authorization_request: ar, user: user, created_at: base_time + 1.day)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 2.days)
        create(:authorization_request_event, :reopen, authorization_request: ar, user: user, created_at: base_time + 10.days)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 11.days)
      end
    end

    let!(:ar2) do
      create(:authorization_request, :validated, applicant: user, organization: organization2, created_at: base_time + 5.days).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time + 5.days)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 5.days + 1.hour)
        create(:authorization_request_event, :reopen, authorization_request: ar, user: user, created_at: base_time + 7.days)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 8.days)
      end
    end

    subject { described_class.new(date_input: 2025) }

    it 'returns the count of reopen events' do
      expect(subject.number_of_reopen_events).to eq('3 reopen events')
    end

    it 'includes the count in the report output' do
      expect { subject.print_report }.to output(/3 reopen events/).to_stdout
    end
  end

  describe 'table formatting methods' do
    let(:base_time) { Time.zone.parse('2025-12-20 10:00:00') }
    let!(:user) { create(:user) }
    let!(:organization) { create(:organization) }
    
    before do
      user.add_to_organization(organization, current: true)
    end

    let!(:api_captchetat_1) do
      create(:authorization_request, :api_captchetat, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 1.hour)
      end
    end

    subject { described_class.new(date_input: 2025) }

    it 'formats table header correctly' do
      header = subject.send(:format_table_header)
      expect(header).to include('Type')
      expect(header).to include('Count')
      expect(header).to include('Min')
      expect(header).to include('Avg')
      expect(header).to include('Max')
    end

    it 'formats table row correctly' do
      stat = {
        type: 'AuthorizationRequest::APIEntreprise',
        count: 5,
        min_time: 3600.0,
        avg_time: 7200.0,
        max_time: 10800.0
      }
      
      row = subject.send(:format_table_row, stat)
      expect(row).to include('API')
      expect(row).to include('Entreprise')
      expect(row).to include('5')
    end

    it 'formats type name without namespace' do
      stat = {
        type: 'AuthorizationRequest::APIEntreprise',
        count: 1,
        min_time: 3600.0,
        avg_time: 3600.0,
        max_time: 3600.0
      }
      
      row = subject.send(:format_table_row, stat)
      expect(row).not_to include('AuthorizationRequest::')
    end
  end

  describe '#print_time_to_submit_by_duration' do
    let(:base_time) { Time.zone.parse('2025-03-15 10:00:00') }
    let!(:user) { create(:user) }
    let!(:organization) { create(:organization) }
    
    before do
      user.add_to_organization(organization, current: true)
    end

    # Create authorization requests with different time to submit
    let!(:ar_quick) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 30.minutes)
      end
    end

    let!(:ar_medium) do
      create(:authorization_request, :api_particulier, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 2.hours)
      end
    end

    let!(:ar_slow) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 5.days)
      end
    end

    subject { described_class.new(date_input: 2025) }

    context 'with step: :minute' do
      it 'outputs bar chart with minute buckets' do
        output = capture_stdout { subject.print_time_to_submit_by_duration(step: :minute) }
        expect(output).to include('Time to submit by minute')
        expect(output).to include('<1')
        expect(output).to include('> 60')
        expect(output).to include('│')
        expect(output).to include('Total:')
      end
    end

    context 'with step: :hour' do
      it 'outputs bar chart with hour buckets' do
        output = capture_stdout { subject.print_time_to_submit_by_duration(step: :hour) }
        expect(output).to include('Time to submit by hour')
        expect(output).to include('<1')
        expect(output).to include('> 24')
        expect(output).to include('│')
        expect(output).to include('Total:')
      end
    end

    context 'with step: :day' do
      it 'outputs bar chart with day buckets' do
        output = capture_stdout { subject.print_time_to_submit_by_duration(step: :day) }
        expect(output).to include('Time to submit by day')
        expect(output).to include('<1')
        expect(output).to include('> 30')
        expect(output).to include('│')
        expect(output).to include('Total:')
      end
    end

    context 'with no data' do
      subject { described_class.new(date_input: 2020) }

      it 'outputs no data message' do
        output = capture_stdout { subject.print_time_to_submit_by_duration(step: :day) }
        expect(output).to include('No data available')
      end
    end
  end

  describe 'filtering by authorization_types' do
    let(:base_time) { Time.zone.parse('2025-03-15 10:00:00') }
    let!(:user) { create(:user) }
    let!(:organization) { create(:organization) }
    
    before do
      user.add_to_organization(organization, current: true)
    end

    # Create authorization requests of different types
    let!(:api_entreprise_1) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 1.hour)
      end
    end

    let!(:api_entreprise_2) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 2.hours)
      end
    end

    let!(:api_particulier_1) do
      create(:authorization_request, :api_particulier, applicant: user, organization: organization, created_at: base_time).tap do |ar|
        create(:authorization_request_event, :create, authorization_request: ar, user: user, created_at: base_time)
        create(:authorization_request_event, :submit, authorization_request: ar, user: user, created_at: base_time + 3.hours)
      end
    end

    context 'when filtering by a single type' do
      subject { described_class.new(date_input: 2025, authorization_types: ['AuthorizationRequest::APIEntreprise']) }

      it 'only counts authorization requests of that type' do
        expect(subject.number_of_authorization_requests_created).to eq('2 authorization requests created')
      end

      it 'includes type filter in report output' do
        output = capture_stdout { subject.print_report }
        expect(output).to include('(types by: APIEntreprise)')
      end
    end

    context 'when filtering by multiple types' do
      subject { described_class.new(date_input: 2025, authorization_types: ['AuthorizationRequest::APIEntreprise', 'AuthorizationRequest::APIParticulier']) }

      it 'counts authorization requests of all specified types' do
        expect(subject.number_of_authorization_requests_created).to eq('3 authorization requests created')
      end

      it 'includes multiple types in filter label' do
        output = capture_stdout { subject.print_report }
        expect(output).to include('(types by: APIEntreprise, APIParticulier)')
      end
    end

    context 'when not filtering by type' do
      subject { described_class.new(date_input: 2025) }

      it 'counts all authorization requests' do
        expect(subject.number_of_authorization_requests_created).to eq('3 authorization requests created')
      end

      it 'does not include type filter in output' do
        output = capture_stdout { subject.print_report }
        expect(output).not_to include('filtered by')
      end
    end

    context 'with time_to_submit_by_duration filtered by type' do
      subject { described_class.new(date_input: 2025, authorization_types: ['AuthorizationRequest::APIEntreprise']) }

      it 'only includes data for filtered types in bar chart' do
        output = capture_stdout { subject.print_time_to_submit_by_duration(step: :hour) }
        expect(output).to include('(types by: APIEntreprise)')
        expect(output).to include('Total: 2 authorization requests')
      end
    end

    context 'with time_to_submit_by_type_table filtered by type' do
      subject { described_class.new(date_input: 2025, authorization_types: ['AuthorizationRequest::APIEntreprise']) }

      it 'only shows statistics for filtered types' do
        output = capture_stdout { subject.print_time_to_submit_by_type_table }
        expect(output).to include('(types by: APIEntreprise)')
      end
    end

    context 'when filtering by provider' do
      let!(:data_provider) { create(:data_provider, slug: 'test-provider', name: 'Test Provider') }
      
      before do
        allow(DataProvider).to receive(:friendly).and_return(DataProvider)
        allow(DataProvider).to receive(:find).with('test-provider').and_return(data_provider)
        
        # Mock authorization definitions for the provider
        api_entreprise_def = instance_double(AuthorizationDefinition, authorization_request_class_as_string: 'AuthorizationRequest::APIEntreprise')
        
        allow(data_provider).to receive(:authorization_definitions).and_return([api_entreprise_def])
      end

      subject { described_class.new(date_input: 2025, provider: 'test-provider') }

      it 'filters by all types belonging to the provider' do
        expect(subject.number_of_authorization_requests_created).to eq('2 authorization requests created')
      end

      it 'shows provider in filter label' do
        output = capture_stdout { subject.print_report }
        expect(output).to include('(provider: test-provider)')
      end

      it 'shows provider filter in bar chart' do
        output = capture_stdout { subject.print_time_to_submit_by_duration(step: :hour) }
        expect(output).to include('(provider: test-provider)')
      end
    end
  end

  # Helper method to capture stdout
  def capture_stdout
    original_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = original_stdout
  end
end
