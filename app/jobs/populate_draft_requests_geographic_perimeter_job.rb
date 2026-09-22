class PopulateDraftRequestsGeographicPerimeterJob < ApplicationJob
  def perform(organization_id)
    organization = Organization.find(organization_id)

    organization.authorization_requests.drafts.find_each do |authorization_request|
      next unless authorization_request.is_a?(AuthorizationExtensions::CnousDataExtractionCriteria)

      authorization_request.populate_codes_insee_and_entity
    end
  # rubocop:disable Lint/SuppressedException
  rescue ActiveRecord::RecordNotFound
  end
  # rubocop:enable Lint/SuppressedException
end
