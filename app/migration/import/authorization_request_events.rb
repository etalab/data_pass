class Import::AuthorizationRequestEvents < Import::Base
  include LocalDatabaseUtils
  include UserLegacyUtils

  def extract(event_row)
    authorization_request = AuthorizationRequest.find(event_row['enrollment_id'])

    case event_row['name']
    when 'create'
      create_event(event_row, entity: authorization_request)
    when 'update'
      if from_admin?(event_row)
        entity = AuthorizationRequestChangelog.create!(authorization_request:, diff: build_event_diff(event_row, authorization_request, relevant_rows: [event_row]))

        create_event(event_row, name: 'admin_update', entity: entity)
      elsif JSON.parse(event_row['diff']).except('_v').present?
        create_event(event_row, entity: authorization_request)
      end
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
      raise 'Not implemented'
    when 'notify'
      user_id = all_users_email_to_id[all_legacy_users_id_to_email[event_row['user_id'].to_i]]

      message = Message.create!(
        body: event_row['comment'],
        from_id: user_id,
        authorization_request: authorization_request,
        sent_at: event_row['created_at'],
        read_at: event_row['created_at'],
      )
      name = event_row['is_notify_from_demandeur'] == 't' ? 'applicant_message' : 'instructor_message'

      create_event(event_row, name:, entity: message)
    when 'request_changes'
      create_event(event_row, entity: InstructorModificationRequest.create!(authorization_request:, reason: event_row['comment']))
    when 'submit'
      create_event(event_row, entity: AuthorizationRequestChangelog.create!(authorization_request:, diff: build_event_diff(event_row, authorization_request)))

      event_created_at = DateTime.parse(event_row['created_at'])

      if authorization_request.last_submitted_at.nil? || event_created_at > authorization_request.last_submitted_at
        authorization_request.update!(last_submitted_at: event_created_at)
      end
    when 'approve', 'validate'
      authorization_request.assign_attributes(
        last_validated_at: event_row['created_at'],
      )

      create_event(event_row, name: 'approve', entity: create_authorization(event_row, authorization_request))
    when 'reopen'
      authorization_request.assign_attributes(
        reopened_at: event_row['created_at'],
      )

      create_event(event_row, entity: find_closest_authorization(event_row, authorization_request))
    when 'refuse'
      create_event(event_row, entity: DenialOfAuthorization.create!(authorization_request:, reason: event_row['comment']))
    when 'revoke'
      create_event(event_row, entity: RevocationOfAuthorization.create!(authorization_request:, reason: event_row['comment']))
    when 'copy'
      return if authorization_request.copied_from_request.blank?

      create_event(event_row, entity: authorization_request)
    end
  end

  private

  def sql_tables_to_save
    @sql_tables_to_save ||= super.concat(
      %w[
        instructor_modification_requests
        authorization_request_changelogs
        denial_of_authorizations
        revocation_of_authorizations
        messages

        authorizations
        authorization_documents
      ]
    )
  end

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
        user_id: extract_user_id(event_row, entity: extra_params[:entity]),
        created_at: event_row['created_at'],
      }.merge(extra_params)
    )
  end

  def extract_user_id(event_row, entity:)
    if all_legacy_users_id_to_email.keys.include?(event_row['user_id'].to_i)
      legacy_user_id_to_user_id(event_row['user_id'])
    elsif %w[create update archive copy].include?(event_row['name'])
      entity.applicant_id
    elsif %w[submit].include?(event_row['name'])
      entity.authorization_request.applicant_id
    end
  end

  def from_admin?(event_row)
    event_row['user_id'].present? &&
      admin_legacy_id_to_external_id.keys.include?(event_row['user_id'].to_s)
  end

  def admin_ids
    @admin_ids ||= database.execute('select id from users where uid in (?)', admin_external_ids).map { |row| row['id'] }
  end

  def admin_legacy_id_to_external_id
    {
      '161' => '243',
      '5475' => '8404',
      '12477' => '16574',
      '13134' => '17210',
      '14932' => '19244',
      '21645' => '34178',
      '21960' => '34758',
    }
  end

  def build_event_diff(event_row, authorization_request, relevant_rows: nil)
    CreateDiffFromEvent.new(event_row, authorization_request, relevant_rows:).perform
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
