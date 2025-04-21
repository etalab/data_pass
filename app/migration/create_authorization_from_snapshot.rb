class CreateAuthorizationFromSnapshot
  include LocalDatabaseUtils

  attr_reader :authorization_request, :event_row

  def initialize(authorization_request, event_row)
    @authorization_request = authorization_request
    @event_row = event_row
  end

  def perform
    snapshot = find_closest_snapshot

    authorization_id = Authorization.where(id: authorization_request.id).any? ? nil : authorization_request.id

    authorization = Authorization.new(
      id: authorization_id,
      request_id: authorization_request.id,
      form_uid: authorization_request.form_uid,
      applicant: authorization_request.applicant,
      created_at: event_datetime,
    )

    # XXX Cas où il y a eu une révocation récente (dunno why ?)
    if snapshot.blank?
      data = authorization_request.data
      authorization.data = data
    else
      snapshot_items = find_snapshot_items(snapshot)
      build_data(authorization, snapshot_items)
    end

    handle_state(authorization)

    authorization.save!

    authorization_request.class.documents.each do |document_identifier|
      storage_file_model = authorization_request.public_send(document_identifier.name)
      next if storage_file_model.blank?

      document = authorization.documents.create!(
        identifier: document_identifier.name,
      )

      Array(storage_file_model).each do |file|
        document.files.attach(file.blob)
      end
    end

    authorization
  end

  private

  def find_closest_snapshot
    if event_datetime.to_date <= initial_creation_date
      data = database.execute(
        'select * from snapshots where enrollment_id = ? order by created_at limit 1',
        authorization_request.id,
      )
    else
      data = database.execute(
        'select * from snapshots where enrollment_id = ? and date(created_at) = ? order by created_at limit 1',
        [
          authorization_request.id,
          event_datetime.to_date.to_s,
        ],
      )
    end

    return if data.empty?

    JSON.parse(data[0][-1]).to_h
  end

  def find_snapshot_items(snapshot)
    database.execute('select * from snapshot_items where snapshot_id = ?', snapshot['id'])
  end

  def build_data(authorization, raw_snapshot_items)
    byebug if raw_snapshot_items.nil?
    snapshot_items = raw_snapshot_items.map { |row| JSON.parse(row[-1]).to_h }

    enrollment_row = JSON.parse(snapshot_items.find { |item| item['item_type'].starts_with?('Enrollment') }['object'])
    team_members = snapshot_items.select { |item| item['item_type'].starts_with?('TeamMember') }.map { |item| JSON.parse(item['object']) }
    temporary_authorization_request = AuthorizationRequest.const_get(authorization_request.type.split('::')[-1]).new
    temporary_authorization_request.organization = authorization_request.organization
    temporary_authorization_request.applicant = authorization_request.applicant
    temporary_authorization_request.form_uid = temporary_authorization_request.definition.available_forms.first.uid

    begin
      Kernel.const_get(
        "Import::AuthorizationRequests::#{authorization_request.type.split('::')[-1]}Attributes"
      ).new(
        temporary_authorization_request,
        enrollment_row,
        team_members,
        [],
        safe_mode: true,
      ).perform
    rescue Import::AuthorizationRequests::Base::SkipRow => e
      print "SkipRow for AuthorizationRequestEvent (not relevant): #{e.inspect}\n"

      authorization.data = authorization_request.data.dup

      return
    end

    authorization.data = temporary_authorization_request.data.dup

    byebug if temporary_authorization_request.persisted?
  end

  def handle_state(authorization)
    state_to_affect = 'obsolete'

    if @authorization_request.state == 'revoked'
      authorization.state = 'revoked'
      authorization.revoked = true
      state_to_affect = 'revoked'
    end

    Authorization.where(request_id: @authorization_request.id).update_all(
      state: state_to_affect,
    )
  end

  def event_datetime
    @event_datetime ||= DateTime.parse(event_row['created_at'])
  end

  def initial_creation_date
    @initial_creation_date ||= Date.new(2024, 2, 21)
  end
end
