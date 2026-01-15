module Stats
  class GenerateReport2023To2025
    def initialize(provider: nil, authorization_types: nil)
      @provider = provider
      @authorization_types = authorization_types
      @years = [2025, 2024, 2023]
    end

    def call
      output_file = prepare_output_file
      
      File.open(output_file, 'w') do |f|
        write_warning(f)
        write_reports(f)
      end

      puts "Report successfully generated: #{output_file}"
      output_file
    end

    private

    def prepare_output_file
      output_dir = Rails.root.join('app', 'services', 'stats', 'results')
      FileUtils.mkdir_p(output_dir)
      
      filename_suffix = if @provider
        "_#{@provider}"
      elsif @authorization_types
        types_str = @authorization_types
          .map { |type| type.gsub('AuthorizationRequest::', '') }
          .join('_')
        "_#{types_str}"
      else
        "_global"
      end
      
      output_dir.join("stats_#{Date.today}#{filename_suffix}.md")
    end

    def write_warning(f)
      f.puts "# ⚠️  Data Quality Warning"
      f.puts ""
      f.puts "2023-2024 data was migrated from DataPass v1 in early 2025."
      f.puts "Event timestamps for these years were reconstructed and may not accurately"
      f.puts "reflect actual user behavior (especially time-to-submit metrics)."
      f.puts ""
      f.puts "=" * 80
      f.puts ""
    end

    def write_reports(f)
      # Temporarily redirect stdout to the file
      original_stdout = $stdout
      $stdout = f

      @years.each do |year|
        report = Stats::Report.new(**report_params(year))
        
        report.print_report
        puts "\n"
        report.print_volume_by_type
        puts "\n"
        report.print_volume_by_type_with_states
        puts "\n"
        report.print_time_to_submit_by_duration(step: :minute)
        puts "\n"
        report.print_time_to_first_instruction_by_duration(step: :day)
        puts "\n"
      end

      # Restore stdout
      $stdout = original_stdout
    end

    def report_params(year)
      params = { date_input: year }
      params[:provider] = @provider if @provider
      params[:authorization_types] = @authorization_types if @authorization_types
      params
    end
  end
end
