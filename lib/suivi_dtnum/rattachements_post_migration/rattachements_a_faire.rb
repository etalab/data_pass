require 'csv'

class RattachementsAFaire
  def initialize
    @csv_file_path = File.join(__dir__, 'ids_fichier_de_suivi.csv')
  end

  def run
    read_csv
    identify_rattachements_to_make

    p @groups.values.map(&:count).group_by(&:itself).map { |k, v| [k, v.count] }
  end

  def read_csv
    @csv = CSV.read(@csv_file_path, headers: true)
  end

  def identify_rattachements_to_make
    @groups = {}

    @csv.each do |row|
      group = find_complete_group(row)
      most_recent = most_recent_of_group(group)
      add_to_group(most_recent["N° Demande v2"], row)
    end

    @groups.select! { |id, group| group.count > 1 && id != nil }
  end

  def add_to_group(group_id, row)
    @groups[group_id] ||= []
    @groups[group_id] << row.to_h
  end

  def find_complete_group(row, group=[])
    group << row
    if row['N° DataPass copié']
      find_complete_group(row['N° DataPass copié'], group)
    else
      group
    end
  end

  def most_recent_of_group(group)
    group.find do |row|
      group.none? { |r| r["N° DataPass copié"] == row["N° DataPass v1"]}
    end
  end
end

RattachementsAFaire.new.run
