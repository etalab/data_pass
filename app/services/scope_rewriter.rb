class ScopeRewriter
  def initialize(authorization_request_types)
    @authorization_request_types = Array(authorization_request_types)
  end

  def rewrite(when_any_of:, &)
    authorization_requests_with_any_of(when_any_of).find_each do |authorization_request|
      rewrite_current_scopes(authorization_request, when_any_of, &)
      shift_changelog_baseline(authorization_request, when_any_of, &)
    end

    authorizations_with_any_of(when_any_of).find_each do |authorization|
      write_scopes(authorization, transform(parse_scopes(authorization.data['scopes']), &))
    end
  end

  private

  attr_reader :authorization_request_types

  def rewrite_current_scopes(authorization_request, trigger_scopes, &)
    current_scopes = parse_scopes(authorization_request.data['scopes'])
    return unless current_scopes.intersect?(trigger_scopes)

    write_scopes(authorization_request, transform(current_scopes, &))
  end

  def transform(scopes)
    yield(scopes).compact_blank.sort
  end

  def write_scopes(record, scopes)
    record.update_column(:data, record.data.merge('scopes' => scopes)) # rubocop:disable Rails/SkipsModelValidations
  end

  def shift_changelog_baseline(authorization_request, trigger_scopes, &)
    last_submitted_scopes = last_changelog_scopes(authorization_request)
    return unless last_submitted_scopes&.intersect?(trigger_scopes)

    shifted_scopes = transform(last_submitted_scopes, &)
    return if shifted_scopes == last_submitted_scopes.sort

    authorization_request.changelogs.create!(diff: { 'scopes' => [last_submitted_scopes, shifted_scopes] })
  end

  def last_changelog_scopes(authorization_request)
    authorization_request.changelogs.order(created_at: :desc).pluck(:diff)
      .find { |diff| diff['scopes'].present? }
      &.dig('scopes', 1)
  end

  def authorization_requests_with_any_of(scopes)
    relation = AuthorizationRequest.where(type: authorization_request_types)

    with_any_of(relation, scopes).or(relation.where(<<~SQL.squish, scopes))
      EXISTS (
        SELECT 1 FROM authorization_request_changelogs changelogs
        WHERE changelogs.authorization_request_id = authorization_requests.id
          AND jsonb_exists_any(changelogs.diff::jsonb -> 'scopes' -> 1, ARRAY[?]::text[])
      )
    SQL
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
