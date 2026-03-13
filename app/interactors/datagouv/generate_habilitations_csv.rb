class Datagouv::GenerateHabilitationsCsv < ApplicationInteractor
  def call
    context.csv_content = generate_csv
  end

  private

  def generate_csv
    CSV.generate(force_quotes: false, col_sep: ',', encoding: 'UTF-8') do |csv|
      csv << Datagouv::BuildHabilitationsRows::CSV_HEADERS
      context.rows.each { |row| csv << row }
    end
  end
end
