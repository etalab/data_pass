class Import::AuthorizationRequestEvents < Import::Base
  include LocalDatabaseUtils

  def extract(event_row)
    authorization_request = AuthorizationRequest.find(event_row['enrollment_id'])

    case event_row['name']
    when 'create', 'update'
      create_event(event_row, entity: authorization_request)
    when 'archive'
      if event_row['user_id'].present?
        create_event(event_row, entity: authorization_request)
      else
        create_event(event_row, name: 'system_archive', entity: authorization_request, user_id: nil)
      end
    when 'reminder_before_archive', 'reminder'
      create_event(event_row, name: 'system_reminder', entity: authorization_request, user_id: nil)
    when 'import'
      # FIXME seulement hubee et FC
    when 'notify'
      user = User.find(event_row['user_id'])
      message = Message.create!(body: event_row['comment'], from: user, authorization_request: authorization_request)
      name = event_row['is_notify_from_demandeur'] == 't' ? 'applicant_message' : 'instructor_message'

      create_event(event_row, name:, entity: message)
    when 'request_changes'
      create_event(event_row, entity: InstructorModificationRequest.create!(authorization_request:, reason: event_row['comment']))
    when 'submit'
      # FIXME retrieve all updates and diffs to create a changelog
      create_event(event_row, entity: AuthorizationRequestChangelog.create!(authorization_request:))
    when 'approve', 'validate'
      create_event(event_row, name: 'approve', entity: create_authorization(event_row, authorization_request))
    when 'reopen'
      create_event(event_row, entity: find_closest_authorization(event_row, authorization_request))
    when 'refuse'
      create_event(event_row, entity: DenialOfAuthorization.create!(authorization_request:, reason: event_row['comment']))
    when 'revoke'
      create_event(event_row, entity: RevocationOfAuthorization.create!(authorization_request:, reason: event_row['comment']))
    end
  end

  private

  def csv_or_table_to_loop
    @rows_from_sql = true
    where_key = "#{model_tableize}_sql_where".to_sym

    query = 'SELECT raw_data FROM events'
    query += " where authorization_request_id in (#{options[:valid_authorization_request_ids].join(',')})"
    query += " and #{options[where_key]}" if options[where_key].present?
    query += ' ORDER BY created_at ASC'
    database.execute(query)
  end

  def create_event(event_row, extra_params = {})
    @models << AuthorizationRequestEvent.create!(
      {
        name: event_row['name'],
        user_id: event_row['user_id'],
        created_at: event_row['created_at'],
      }.merge(extra_params)
    )
  end

  def create_authorization(event_row, authorization_request)
    CreateAuthorizationFromSnapshot.new(authorization_request, event_row).perform
  end

  def find_closest_authorization(event_row, authorization_request)
    Authorization.where(
      request_id: authorization_request.id
    ).order(created_at: :desc).first
  end
end
