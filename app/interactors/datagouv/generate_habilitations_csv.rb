class Datagouv::GenerateHabilitationsCsv < ApplicationInteractor
  def call
    context.csv_path = Rails.root.join('tmp', "habilitations-datapass-#{Time.zone.now.to_i}.csv").to_s
    write_csv
  end

  private

  def write_csv
    CSV.open(context.csv_path, 'w', force_quotes: false, col_sep: ',', encoding: 'UTF-8') do |csv|
      csv << Datagouv::BuildHabilitationsRows::CSV_HEADERS
      context.rows.each { |row| csv << row }
    end
  end
end
