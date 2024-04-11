class CreateAuthorizationFromSnapshot
  include LocalDatabaseUtils

  def initialize(authorization_request, event_row)
    @authorization_request = authorization_request
    @event_row = event_row
  end

  def perform
    snapshot = find_closest_snapshot
    snapshot_items = find_snapshot_items(snapshot)

    Authorization.create!(
      request_id: authorization_request.id,
      applicant: authorization_request.applicant,
      data: build_data(snapshot_items)
    )
  end

  private

  def find_closest_snapshot
    if event_datetime.to_date <= initial_creation_date
      database.execute(
        'select * from snapshots where item_id = ? order by created_at limit 1',
        authorization_request.id,
      )
    else
      database.execute(
        'select * from snapshots where item_id = ? and date(created_at) = ? order by created_at limit 1',
        authorization_request.id,
        event_datetime.to_date,
      )
    end
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
