module Stats
  class BacklogEvolutionQuery < BaseStatsQuery
    private

    def calculate_backlog_at(timestamp)
      archived_or_revoked_ids = AuthorizationRequest
        .where(state: %w[archived revoked])
        .pluck(:id)

      submit_events = AuthorizationRequestEvent
        .select(:id, :authorization_request_id, :created_at)
        .where(name: 'submit')
        .where(created_at: ..timestamp)
        .where.not(authorization_request_id: nil)
        .where.not(authorization_request_id: archived_or_revoked_ids)
        .order(:authorization_request_id, created_at: :desc)

      instruction_events = AuthorizationRequestEvent
        .select(:id, :authorization_request_id, :created_at)
        .where(name: %w[approve refuse request_changes])
        .where(created_at: ..timestamp)
        .where.not(authorization_request_id: nil)
        .order(:authorization_request_id, created_at: :desc)

      submit_by_request = submit_events.group_by(&:authorization_request_id)
      instruction_by_request = instruction_events.group_by(&:authorization_request_id)

      uninstructed_count = 0

      submit_by_request.each do |request_id, submits|
        last_submit = submits.first
        instructions = instruction_by_request[request_id] || []

        instructions_after_last_submit = instructions.select do |instruction|
          instruction.created_at > last_submit.created_at
        end

        uninstructed_count += 1 if instructions_after_last_submit.empty?
      end

      uninstructed_count
    end
  end
end
