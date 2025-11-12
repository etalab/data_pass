require 'csv'
require 'net/http'
require 'yaml'

module AdminTooling
  class ImportEligibilityRules
    EXPECTED_TARGET_AUDIENCES = ['collectivité ou administration', 'entreprise ou association', 'particulier'].sort.freeze

    def self.call(csv_url, output_path: nil)
      new(csv_url, output_path).call
    end

    def initialize(csv_url, output_path)
      @csv_url = csv_url
      @output_path = output_path || Rails.root.join('db/data/eligibility_rules.yml')
    end

    def call
      csv_data = fetch_csv
      grouped_data = parse_and_group_csv(csv_data)
      result = process_groups(grouped_data)
      write_yaml(result[:rules])

      { imported: result[:imported], skipped: result[:skipped] }
    end

    private

    def fetch_csv
      uri = URI(@csv_url)
      response = Net::HTTP.get_response(uri)
      raise "Failed to fetch CSV: #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      response.body
    end

    def parse_and_group_csv(csv_data)
      rows = CSV.parse(csv_data, headers: true, encoding: 'UTF-8')
      rows.group_by { |row| row['ID Datapass'] }
    end

    def process_groups(grouped_data)
      rules = []
      imported = []
      skipped = []
      id_counter = 1

      grouped_data.each do |definition_id, rows|
        next if definition_id.nil? || definition_id.strip.empty?

        if valid_group?(rows)
          rules << build_rule(id_counter, definition_id, rows)
          imported << definition_id
          id_counter += 1
        else
          skipped << definition_id
        end
      end

      { rules:, imported:, skipped: }
    end

    def valid_group?(rows)
      target_audiences = rows.pluck('Public Cible').sort
      target_audiences == EXPECTED_TARGET_AUDIENCES
    end

    def build_rule(id, definition_id, rows)
      {
        'id' => id,
        'definition_id' => definition_id.underscore,
        'options' => rows.map { |row| build_option(row) }
      }
    end

    def build_option(row)
      option = {
        'type' => normalize_type(row['Public Cible']),
        'eligible' => normalize_eligible(row['Eligible']),
        'body' => row['phrase'].to_s
      }

      cta_link = row['CTA']
      if cta_link.present?
        option['cta'] = {
          'content' => row['Texte du CTA'],
          'url' => cta_link
        }
      end

      option
    end

    def normalize_type(public_cible)
      {
        'particulier' => 'particulier',
        'collectivité ou administration' => 'collectivite_ou_administration',
        'entreprise ou association' => 'entreprise_ou_association'
      }[public_cible]
    end

    def normalize_eligible(eligible_value)
      {
        'Oui' => 'yes',
        'Non' => 'no',
        'Peut-être' => 'maybe'
      }[eligible_value]
    end

    def write_yaml(rules)
      FileUtils.mkdir_p(File.dirname(@output_path))
      File.write(@output_path, rules.to_yaml)
    end
  end
end
