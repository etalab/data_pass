class ScopeMigrationService
  def initialize(authorization_request_type, mapping)
    @authorization_request_type = authorization_request_type
    @mapping = normalize_mapping(mapping)
  end

  def up
    migrate(
      authorization_requests_with(@mapping.keys),
      authorization_authorizations_with(@mapping.keys),
      @mapping
    )
  end

  def down
    reversed = @mapping.each_with_object({}) { |(old_scopes, new_scopes), h| h[new_scopes] = old_scopes }
    migrate(
      authorization_requests_with(reversed.keys),
      authorization_authorizations_with(reversed.keys),
      reversed
    )
  end

  private

  attr_reader :authorization_request_type

  def migrate(requests, authorizations, mapping)
    [requests, authorizations].each do |scope|
      scope.find_each do |record|
        scopes = parse_scopes(record.data['scopes'])
        new_scopes = apply_mapping(scopes, mapping)
        record.update_column(:data, record.data.merge('scopes' => new_scopes.to_json)) # rubocop:disable Rails/SkipsModelValidations
      end
    end
  end

  def apply_mapping(scopes, mapping)
    mapping.each_with_object(scopes.dup) { |(old_scopes, new_scopes), result|
      next unless result.intersect?(old_scopes)

      result.reject! { |s| old_scopes.include?(s) }
      result.concat(new_scopes)
    }.sort.uniq
  end

  def authorization_requests_with(scope_sets)
    AuthorizationRequest
      .where(type: authorization_request_type)
      .where("data ? 'scopes'")
      .where(any_scope_present_sql(scope_sets.flatten.uniq))
  end

  def authorization_authorizations_with(scope_sets)
    Authorization
      .where(authorization_request_class: authorization_request_type)
      .where("data ? 'scopes'")
      .where(any_scope_present_sql(scope_sets.flatten.uniq))
  end

  def any_scope_present_sql(scopes)
    quoted = scopes.map { |s| "'#{s}'" }.join(', ')
    "EXISTS (SELECT 1 FROM jsonb_array_elements_text((data->'scopes')::jsonb) AS s WHERE s IN (#{quoted}))"
  end

  def parse_scopes(value)
    return [] if value.blank?

    Array(JSON.parse(value))
  rescue JSON::ParserError
    []
  end

  def normalize_mapping(mapping)
    mapping.transform_keys { |k| Array(k) }.transform_values { |v| Array(v) }
  end
end
