class AuthorizationRequestEventsQuery
  attr_reader :authorization_request

  def initialize(authorization_request)
    @authorization_request = authorization_request
  end

  def perform
    AuthorizationRequestEvent
      .where(
        "(entity_id = ? AND entity_type = 'AuthorizationRequest') OR (entity_id in (?) AND entity_type = 'DenialOfAuthorization') OR (entity_id in (?) and entity_type = 'InstructorModificationRequest')",
        authorization_request.id,
        authorization_request.denials.pluck(:id),
        authorization_request.modification_requests.pluck(:id),
      )
  end
end
