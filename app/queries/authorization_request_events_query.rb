class AuthorizationRequestEventsQuery
  attr_reader :authorization_request

  def initialize(authorization_request)
    @authorization_request = authorization_request
  end

  def perform
    events = AuthorizationRequestEvent
      .includes(%i[authorization_request])
      .where(
        "(authorization_request_id = ? AND name != 'bulk_update') OR " \
        "(entity_id in (?) AND entity_type = 'BulkAuthorizationRequestUpdate')",
        authorization_request.id,
        authorization_request.bulk_updates.pluck(:id)
      ).order(
        created_at: :desc,
      )

    events = remove_adjacent_updates(events)

    AuthorizationRequestEvent.where(id: events.map(&:id)).order(created_at: :desc)
  end

  private

  def remove_adjacent_updates(events)
    events.chunk_while { |e1, e2| e1.name == e2.name && e1.name == 'update' }.map(&:first)
  end
end
