class Import::Events < Import::Base
  def extract(event_row)
    authorization_request = AuthorizationRequest.find(event_row['enrollment_id'])

    case event_row['name']
    when 'create', 'update', 'archive'
      create_event(event_row, entity: authorization_request)
    end
  end

  private

  def create_event(event_row, extra_params = {})
    AuthorizationRequestEvent.create!(
      {
        name: event_row['name'],
        user_id: event_row['user_id'],
      }.merge(extra_params)
    )
  end
end
