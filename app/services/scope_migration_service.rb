class ScopeMigrationService
  def initialize(authorization_request_types, mapping)
    @rewriter = ScopeRewriter.new(authorization_request_types)
    @mapping = normalize_mapping(mapping)
  end

  def up
    migrate(mapping)
  end

  def down
    migrate(mapping.invert)
  end

  private

  attr_reader :rewriter, :mapping

  def migrate(mapping)
    rewriter.rewrite(when_any_of: mapping.keys.flatten.uniq) { |scopes| apply_mapping(scopes, mapping) }
  end

  def apply_mapping(scopes, mapping)
    mapping.each_with_object(scopes.dup) { |(old_scopes, new_scopes), result|
      next unless result.intersect?(old_scopes)

      result.reject! { |s| old_scopes.include?(s) }
      result.concat(new_scopes)
    }.uniq
  end

  def normalize_mapping(mapping)
    mapping.transform_keys { |k| Array(k) }.transform_values { |v| Array(v) }
  end
end
