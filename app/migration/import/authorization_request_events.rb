class Import::AuthorizationRequestEvents < Import::Base
  include LocalDatabaseUtils
  include UserLegacyUtils

  def extract(event_row)
    authorization_request = extract_authorization_request(event_row)
    @authorization_request = authorization_request
    # byebug if authorization_request.blank?
    return if authorization_request.blank?

    case event_row['name']
    when 'create'
      return if authorization_request.definition.stage.exists? && authorization_request.definition.stage.type == 'production'

      create_event(event_row, entity: authorization_request)
    when 'update'
      if from_admin?(event_row)
        entity = AuthorizationRequestChangelog.create!(authorization_request:, diff: build_event_diff(event_row, authorization_request, relevant_rows: [event_row]))

        create_event(event_row, name: 'admin_update', entity: entity)
      elsif JSON.parse(event_row['diff'] || '{}').except('_v').present?
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
      create_event(event_row, name: 'system_import', entity: authorization_request, user_id: nil)
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
      create_event(event_row, entity: InstructorModificationRequest.create!(authorization_request:, reason: event_row['comment'] || default_reason))
    when 'submit'
      create_event(event_row, entity: AuthorizationRequestChangelog.create!(authorization_request:, diff: build_event_diff(event_row, authorization_request), legacy: true))

      event_created_at = DateTime.parse(event_row['created_at'])

      if authorization_request.last_submitted_at.nil? || event_created_at > authorization_request.last_submitted_at
        authorization_request.assign_attributes(last_submitted_at: event_created_at)
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
      create_event(event_row, entity: DenialOfAuthorization.create!(authorization_request:, reason: event_row['comment'] || default_reason))
    when 'revoke'
      create_event(event_row, entity: RevocationOfAuthorization.create!(authorization_request:, reason: event_row['comment'] || default_reason))
    when 'copy'
      create_event(event_row, entity: authorization_request)
    end

    authorization_request.save(validate: false)
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
    query += ' where (1=1)'
    query += " and authorization_request_id in (#{build_authorization_request_ids})" if options[:valid_authorization_request_ids].present?
    query += " and #{options[where_key]}" if options[where_key].present?
    query += ' ORDER BY created_at ASC'

    database.execute(query)
  end

  def build_authorization_request_ids
    (
      options[:valid_authorization_request_ids].concat(
        options[:global_enrollment_ids_to_import_for_events],
      )
    ).join(',')
  end

  def create_event(event_row, extra_params = {})
    @models << AuthorizationRequestEvent.create!(
      {
        name: event_row['name'],
        user_id: extract_user_id(event_row, entity: extra_params[:entity]),
        created_at: event_row['created_at'],
        authorization_request: @authorization_request,
      }.merge(extra_params)
    )
  end

  def extract_user_id(event_row, entity:)
    return if %w(reminder_before_archive reminder).include?(event_row['name'])

    if all_legacy_users_id_to_email.keys.include?(event_row['user_id'].to_i)
      legacy_user_id_to_user_id(event_row['user_id']) ||
        create_user_from_legacy_id(event_row, entity)
    elsif %w[create update archive copy].include?(event_row['name'])
      entity.applicant_id
    elsif %w[submit].include?(event_row['name'])
      entity.authorization_request.applicant_id
    else
      raise "Unknown user_id for event #{event_row['name']}"
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
    authorization_request.authorizations.sort_by do |authorization|
      (authorization.created_at.to_i - DateTime.parse(event_row['created_at']).to_i).abs
    end.first
  end

  def create_user_from_legacy_id(event_row, entity)
    legacy_user_id = event_row['user_id']
    legacy_user_row = database.execute('select * from users where id = ?', legacy_user_id).first

    case event_row['name']
    when 'create', 'update', 'archive', 'submit', 'copy', 'import'
      organization = entity.organization
    when 'validate', 'request_changes', 'approve', 'refuse', 'revoke'
      organization = extract_instruction_organization(entity)
    else
      raise "Unknown user_id for event #{event_row['name']}"
    end

    existing_user = User.find_by(external_id: legacy_user_row[1])

    return existing_user.id if existing_user.present?

    user = User.new(email: legacy_user_row[-1], external_id: legacy_user_row[1], current_organization: organization)
    user.save!
    user.id
  end

  def extract_instruction_organization(entity)
    authorization_request = entity.authorization_request

    case authorization_request.type
    when 'AuthorizationRequest::APIParticulier', 'AuthorizationRequest::APIEntreprise', 'AuthorizationRequest::FranceConnect'
      @dinum_organization ||= Organization.find_by(legal_entity_id: '13002526500013', legal_entity_registry: "insee_sirene")
    when 'AuthorizationRequest::HubEECertDC'
      @dgs_organization ||= Organization.find_by(legal_entity_id: '13001653800014', legal_entity_registry: "insee_sirene")
    when 'AuthorizationRequest::HubEEDila'
      @dila_organization ||= Organization.find_by(legal_entity_id: '13000918600011', legal_entity_registry: "insee_sirene")
    when 'AuthorizationRequest::LeTaxi'
      @le_taxi_organization ||= Organization.find_by(legal_entity_id: '12000018700027', legal_entity_registry: "insee_sirene")
    else
      raise "Unknown authorization request type #{authorization_request.type} for instruction"
    end
  end

  def extract_authorization_request(event_row)
    AuthorizationRequest.find_by(id: event_row['enrollment_id']) ||
      AuthorizationRequest.where(
        id: database.execute(
          'select id from enrollments where previous_enrollment_id = ? and id > ?',
          database.execute(
            'select previous_enrollment_id from enrollments where id = ?',
            [event_row['enrollment_id']]
          )[0] + [event_row['enrollment_id']]
        ).flatten
      ).first
  end

  def default_reason
    '(Aucune raison donnée : donnée absente en base de données)'
  end
end
