require 'rails_helper'

RSpec.describe Stats::GenerateReport2023To2025, type: :service do
  let(:output_dir) { Rails.root.join('app', 'services', 'stats', 'results') }
  let(:today) { Date.today }

  describe '#initialize' do
    context 'with default parameters' do
      subject { described_class.new }

      it 'sets default values' do
        expect(subject.instance_variable_get(:@provider)).to be_nil
        expect(subject.instance_variable_get(:@authorization_types)).to be_nil
        expect(subject.instance_variable_get(:@post_migration_only)).to be false
        expect(subject.instance_variable_get(:@years)).to eq([2025, 2024, 2023])
      end
    end

    context 'with post_migration_only: true' do
      subject { described_class.new(post_migration_only: true) }

      it 'sets years to [2025] only' do
        expect(subject.instance_variable_get(:@years)).to eq([2025])
      end

      it 'sets post_migration_only flag' do
        expect(subject.instance_variable_get(:@post_migration_only)).to be true
      end
    end

    context 'with provider' do
      subject { described_class.new(provider: 'test-provider') }

      it 'sets the provider' do
        expect(subject.instance_variable_get(:@provider)).to eq('test-provider')
      end
    end

    context 'with authorization_types' do
      subject { described_class.new(authorization_types: ['AuthorizationRequest::APIEntreprise']) }

      it 'sets the authorization types' do
        expect(subject.instance_variable_get(:@authorization_types)).to eq(['AuthorizationRequest::APIEntreprise'])
      end
    end
  end

  describe '#call' do
    let(:service) { described_class.new }
    let(:output_file) { output_dir.join("stats_#{today}_global.md") }
    let(:report_double) do
      double(
        print_report: nil,
        print_volume_by_type: nil,
        print_volume_by_type_with_states: nil,
        print_median_time_to_submit_by_type: nil,
        print_time_to_submit_by_duration: nil,
        print_median_time_to_first_instruction_by_type: nil,
        print_time_to_first_instruction_by_duration: nil
      )
    end

    before do
      # Clean up any existing test files
      FileUtils.rm_f(output_file)
      allow(Stats::Report).to receive(:new).and_return(report_double)
      # Suppress stdout for the success message
      allow($stdout).to receive(:puts)
    end

    after do
      FileUtils.rm_f(output_file)
    end

    it 'generates a report file' do
      result = service.call
      expect(File.exist?(result)).to be true
      expect(result.to_s).to include("stats_#{today}_global.md")
    end

    context 'with post_migration_only: true' do
      let(:service) { described_class.new(post_migration_only: true) }
      let(:output_file) { output_dir.join("stats_#{today}_global.md") }

      it 'includes the post-migration warning' do
        service.call
        content = File.read(output_file)
        expect(content).to include('⚠️ Données uniquement à partir du')
        expect(content).to include('01/06/2025')
        expect(content).to include('date de la migration vers DataPass v2')
        expect(content).not_to include('Attention à la qualité des données')
      end

      it 'only processes year 2025 with date range' do
        years_called = []
        allow(Stats::Report).to receive(:new) do |args|
          years_called << args[:date_input]
          report_double
        end
        service.call
        expect(years_called.length).to eq(1)
        expect(years_called.first).to be_a(Range)
        expect(years_called.first.first).to eq(Date.new(2025, 6, 1))
        expect(years_called.first.last).to eq(Date.today)
      end
    end

    context 'with post_migration_only: false' do
      let(:service) { described_class.new(post_migration_only: false) }

      it 'includes the data quality warning' do
        service.call
        content = File.read(output_file)
        expect(content).to include('⚠️ Attention à la qualité des données')
        expect(content).to include('Les données de 2023-2024 ont été migrées')
        expect(content).not_to include('Données uniquement à partir du')
      end

      it 'processes all years (2025, 2024, 2023)' do
        years_called = []
        allow(Stats::Report).to receive(:new) do |args|
          years_called << args[:date_input] if args[:date_input].is_a?(Integer)
          report_double
        end
        service.call
        expect(years_called).to include(2025, 2024, 2023)
      end
    end

    context 'with provider' do
      let(:service) { described_class.new(provider: 'test-provider') }
      let(:output_file) { output_dir.join("stats_#{today}_test-provider.md") }

      it 'generates file with provider suffix' do
        result = service.call
        expect(result.to_s).to include("stats_#{today}_test-provider.md")
      end

      it 'passes provider to report' do
        providers_called = []
        allow(Stats::Report).to receive(:new) do |args|
          providers_called << args[:provider] if args[:provider]
          report_double
        end
        service.call
        expect(providers_called).to include('test-provider')
      end
    end

    context 'with authorization_types' do
      let(:service) { described_class.new(authorization_types: ['AuthorizationRequest::APIEntreprise']) }
      let(:output_file) { output_dir.join("stats_#{today}_APIEntreprise.md") }

      it 'generates file with authorization types suffix' do
        result = service.call
        expect(result.to_s).to include("stats_#{today}_APIEntreprise.md")
      end

      it 'passes authorization_types to report' do
        types_called = []
        allow(Stats::Report).to receive(:new) do |args|
          types_called << args[:authorization_types] if args[:authorization_types]
          report_double
        end
        service.call
        expect(types_called).to include(['AuthorizationRequest::APIEntreprise'])
      end
    end
  end

  describe 'report_params' do
    context 'with post_migration_only: true and year 2025' do
      let(:service) { described_class.new(post_migration_only: true) }

      it 'converts year to date range from June 1, 2025 to today' do
        params = service.send(:report_params, 2025)
        expect(params[:date_input]).to be_a(Range)
        expect(params[:date_input].first).to eq(Date.new(2025, 6, 1))
        expect(params[:date_input].last).to eq(Date.today)
      end
    end

    context 'with post_migration_only: false' do
      let(:service) { described_class.new(post_migration_only: false) }

      it 'keeps year as integer' do
        params = service.send(:report_params, 2025)
        expect(params[:date_input]).to eq(2025)

        params = service.send(:report_params, 2024)
        expect(params[:date_input]).to eq(2024)

        params = service.send(:report_params, 2023)
        expect(params[:date_input]).to eq(2023)
      end
    end

    context 'with provider' do
      let(:service) { described_class.new(provider: 'test-provider', post_migration_only: true) }

      it 'includes provider in params' do
        params = service.send(:report_params, 2025)
        expect(params[:provider]).to eq('test-provider')
      end
    end

    context 'with authorization_types' do
      let(:service) { described_class.new(authorization_types: ['AuthorizationRequest::APIEntreprise'], post_migration_only: true) }

      it 'includes authorization_types in params' do
        params = service.send(:report_params, 2025)
        expect(params[:authorization_types]).to eq(['AuthorizationRequest::APIEntreprise'])
      end
    end
  end
end
