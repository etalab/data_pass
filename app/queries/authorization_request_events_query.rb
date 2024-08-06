class AuthorizationRequestEventsQuery
  attr_reader :authorization_request

  def initialize(authorization_request)
    @authorization_request = authorization_request
  end

  def perform
    AuthorizationRequestEvent
      .includes(%i[user entity])
      .where(
        sql_query,
        *model_ids,
      )
  end

  private

  # rubocop:disable Metrics/AbcSize
  def model_ids
    [
      authorization_request.id,
      authorization_request.denial_ids,
      authorization_request.modification_request_ids,
      authorization_request.changelog_ids,
      authorization_request.message_ids,
      authorization_request.authorization_ids,
      authorization_request.revocation_ids,
      authorization_request.transfer_ids,
      authorization_request.reopening_cancellation_ids,
    ]
  end
  # rubocop:enable Metrics/AbcSize

  def sql_query
    "(entity_id = ? and entity_type = 'AuthorizationRequest') or " \
      "(entity_id in (?) and entity_type = 'DenialOfAuthorization') or " \
      "(entity_id in (?) and entity_type = 'InstructorModificationRequest') or " \
      "(entity_id in (?) and entity_type = 'AuthorizationRequestChangelog') or " \
      "(entity_id in (?) and entity_type = 'Message') or " \
      "(entity_id in (?) and entity_type = 'Authorization') or" \
      "(entity_id in (?) and entity_type = 'RevocationOfAuthorization') or" \
      "(entity_id in (?) and entity_type = 'AuthorizationRequestTransfer') or" \
      "(entity_id in (?) and entity_type = 'AuthorizationRequestReopeningCancellation')"
  end
end
