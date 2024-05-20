class CreateAuthorizationFromSnapshot
  include LocalDatabaseUtils

  attr_reader :authorization_request, :event_row

  def initialize(authorization_request, event_row)
    @authorization_request = authorization_request
    @event_row = event_row
  end

  def perform
    snapshot = find_closest_snapshot

    # XXX Cas où il y a eu une révocation récente (dunno why ?)
    if snapshot.blank?
      data = authorization_request.data
    else
      snapshot_items = find_snapshot_items(snapshot)
      data = build_data(snapshot_items)
    end

    authorization = Authorization.create!(
      request_id: authorization_request.id,
      applicant: authorization_request.applicant,
      data: build_data(snapshot_items),
      created_at: event_datetime,
    )

    authorization_request.class.documents.each do |document_identifier|
      storage_file_model = authorization_request.public_send(document_identifier)
      next if storage_file_model.blank?

      document = authorization.documents.create!(
        identifier: document_identifier,
      )
      document.file.attach(storage_file_model.blob)
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

  # FIXME que 26 raws clairement ça va se faire à la main je pense
  def build_data(snapshot_items)
    authorization_request.data
  end

  def event_datetime
    @event_datetime ||= DateTime.parse(event_row['created_at'])
  end

  def initial_creation_date
    @initial_creation_date ||= Date.new(2024, 2, 21)
  end
end
