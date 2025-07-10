module Searchable
  extend ActiveSupport::Concern

  included do
    def self.ransackable_attributes(_auth_object = nil)
      base_attributes = %w[
        id
        created_at
        updated_at
        within_data
        api_service_name
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
      Arel.sql("#{table_name}.data::text")
    end

    ransacker :api_service_name do |_parent|
      table = Authorization.arel_table

      name = AuthorizationDefinition.all.reduce(table[:authorization_request_class]) do |case_expression, definition|
        case_expression.when(definition.authorization_request_class_as_string).then(definition.name.humanize)
      end

      name
    end

    def self.search_by_query(query)
      return all if query.blank?

      if query.match?(/^\d+$/)
        where(id: query.to_i)
      else
        ransack(
          within_data_or_api_service_name_cont: query,
          m: 'or',
          applicant_email_cont: query,
          applicant_family_name_cont: query,
          applicant_given_name_cont: query
        ).result
      end
    end
  end

  class_methods do
    def model_specific_ransackable_attributes
      []
    end
  end
end
