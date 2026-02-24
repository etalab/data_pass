class Stats::VolumeStatsQuery < Stats::BaseStatsQuery
  def total_requests_submitted_count
    AuthorizationRequestEvent
      .where(name: 'submit')
      .where(authorization_request_id: filtered_requests.select(:id))
      .where(created_at: date_range)
      .count
  end

  def new_requests_submitted_count
    filtered_requests_with_first_submit_in_range.count
  end

  def reopenings_submitted_count
    reopenings_with_subsequent_submit.count
  end

  def validations_count
    AuthorizationRequestEvent
      .where(name: 'approve')
      .where(authorization_request_id: filtered_requests.select(:id))
      .where(created_at: date_range)
      .count
  end

  def refusals_count
    AuthorizationRequestEvent
      .where(name: 'refuse')
      .where(authorization_request_id: filtered_requests.select(:id))
      .where(created_at: date_range)
      .count
  end
end
