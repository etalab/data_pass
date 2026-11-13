class ScopeBackfillService
  def initialize(authorization_request_types, added_scope:, when_any_of:)
    @authorization_request_types = Array(authorization_request_types)
    @added_scope = added_scope
    @trigger_scopes = Array(when_any_of)
  end

  def up
    update_scopes(trigger_scopes) { |scopes| scopes | [added_scope] }
  end

  def down
    update_scopes([added_scope]) { |scopes| scopes - [added_scope] }
  end

  private

  attr_reader :authorization_request_types, :added_scope, :trigger_scopes

  def update_scopes(selecting_scopes, &)
    authorization_requests_with_any_of(selecting_scopes).find_each do |authorization_request|
      update_authorization_request(authorization_request, &)
    end

    authorizations_with_any_of(selecting_scopes).find_each do |authorization|
      write_scopes(authorization, yield(parse_scopes(authorization.data['scopes'])))
    end
  end

  def update_authorization_request(authorization_request, &)
    write_scopes(authorization_request, yield(parse_scopes(authorization_request.data['scopes'])))
    shift_changelog_baseline(authorization_request, &)
  end

  def shift_changelog_baseline(authorization_request)
    last_submitted_scopes = last_changelog_scopes(authorization_request)
    return if last_submitted_scopes.nil?

    shifted_scopes = yield(last_submitted_scopes).compact_blank.sort
    return if shifted_scopes == last_submitted_scopes.sort

    authorization_request.changelogs.create!(diff: { 'scopes' => [last_submitted_scopes, shifted_scopes] })
  end

  def last_changelog_scopes(authorization_request)
    authorization_request.changelogs.order(created_at: :desc).pluck(:diff)
      .find { |diff| diff['scopes'].present? }
      &.dig('scopes', 1)
  end

  def write_scopes(record, scopes)
    scopes.compact_blank.sort.tap do |sorted_scopes|
      record.update_column(:data, record.data.merge('scopes' => sorted_scopes)) # rubocop:disable Rails/SkipsModelValidations
    end
  end

  def authorization_requests_with_any_of(scopes)
    with_any_of(AuthorizationRequest.where(type: authorization_request_types), scopes)
  end

  def authorizations_with_any_of(scopes)
    with_any_of(Authorization.where(authorization_request_class: authorization_request_types), scopes)
  end

  def with_any_of(relation, scopes)
    relation
      .where("data ? 'scopes'")
      .where("EXISTS (SELECT 1 FROM jsonb_array_elements_text((data->'scopes')::jsonb) AS s WHERE s IN (?))", scopes)
  end

  def parse_scopes(value)
    return [] if value.blank?

    Array(JSON.parse(value))
  rescue JSON::ParserError
    []
  end
end
