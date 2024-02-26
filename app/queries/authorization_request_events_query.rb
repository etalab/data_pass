class AuthorizationRequestEventsQuery
  attr_reader :authorization_request

  def initialize(authorization_request)
    @authorization_request = authorization_request
  end

  def perform
    AuthorizationRequestEvent
      .where(
        sql_query,
        authorization_request.id,
        authorization_request.denials.pluck(:id),
        authorization_request.modification_requests.pluck(:id),
        authorization_request.changelogs.pluck(:id),
        authorization_request.authorizations.pluck(:id),
      )
  end

  private

  def sql_query
    "(entity_id = ? and entity_type = 'AuthorizationRequest') or " \
      "(entity_id in (?) and entity_type = 'DenialOfAuthorization') or " \
      "(entity_id in (?) and entity_type = 'InstructorModificationRequest') or " \
      "(entity_id in (?) and entity_type = 'AuthorizationRequestChangelog') or " \
      "(entity_id in (?) and entity_type = 'Authorization')"
  end
end
