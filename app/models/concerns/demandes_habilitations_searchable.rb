module DemandesHabilitationsSearchable
  extend ActiveSupport::Concern

  included do
    def self.ransackable_attributes(_auth_object = nil)
      base_attributes = %w[
        id
        created_at
        updated_at
        within_data
      ]

      base_attributes + model_specific_ransackable_attributes
    end

    def self.ransackable_associations(_auth_object = nil)
      %w[
        applicant
        organization
      ]
    end

    ransacker :within_data do |_parent|
      table_name = model_name.plural
      Arel.sql("#{connection.quote_table_name(table_name)}.data::text")
    end

    def self.search_by_query(query)
      return all if query.blank?

      extracted_id = extract_id_from_query(query)
      if extracted_id
        where(id: extracted_id)
      else
        ransack(
          within_data_cont: query,
          m: 'or',
          applicant_email_cont: query,
          applicant_family_name_cont: query,
          applicant_given_name_cont: query
        ).result
      end
    end

    def self.extract_id_from_query(query)
      return query.to_i if query.match?(/^\d+$/)

      match = query.match(/^[DH](\d+)$/i)
      match[1].to_i if match
    end
  end

  class_methods do
    def model_specific_ransackable_attributes
      []
    end
  end
end
