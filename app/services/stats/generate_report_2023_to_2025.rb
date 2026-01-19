module Stats
  MIGRATION_DATE = Date.new(2025, 6, 18)

  class GenerateReport2023To2025
    def initialize(provider: nil, authorization_types: nil, post_migration_only: false)
      @provider = provider
      @authorization_types = authorization_types
      @post_migration_only = post_migration_only
      @years = post_migration_only ? [2025] : [2025, 2024]
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
      if @post_migration_only
        f.puts "> **⚠️ Données uniquement à partir du #{MIGRATION_DATE.strftime('%d/%m/%Y')}, date de la migration vers DataPass v2 **"
      else
        f.puts "> **⚠️ Attention à la qualité des données**"
        f.puts "> "
        f.puts "> Les données de 2023-2024 ont été migrées depuis DataPass v1 en début 2025. Certains évènements de ces années ont été reconstitués et peuvent ne pas refléter exactement le comportement des utilisateurs - en particulier les métriques de durée desoumission."
      end

      f.puts ""
      f.puts "---"
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
        report.print_median_time_to_submit_by_type
        puts "\n"
        report.print_time_to_submit_by_duration(step: :minute)
        puts "\n"
        report.print_median_time_to_first_instruction_by_type
        puts "\n"
        report.print_time_to_first_instruction_by_duration(step: :day)
        puts "\n"
        
        if report.dgfip_report?
          report.print_median_time_to_production_instruction_by_type
          puts "\n"
          report.print_time_to_production_instruction_by_duration(step: :day)
          puts "\n"
        end
      end

      # Restore stdout
      $stdout = original_stdout
    end

    def report_params(year)
      date_input = if @post_migration_only && year == 2025
        MIGRATION_DATE..Date.today
      else
        year
      end
      
      params = { date_input: date_input }
      params[:provider] = @provider if @provider
      params[:authorization_types] = @authorization_types if @authorization_types
      params
    end
  end
end
