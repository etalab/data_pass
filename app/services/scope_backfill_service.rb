class ScopeBackfillService
  def initialize(authorization_request_types, added_scope:, when_any_of:)
    @rewriter = ScopeRewriter.new(authorization_request_types)
    @added_scope = added_scope
    @trigger_scopes = Array(when_any_of)
  end

  def up
    rewriter.rewrite(when_any_of: trigger_scopes) { |scopes| scopes | [added_scope] }
  end

  def down
    rewriter.rewrite(when_any_of: [added_scope]) { |scopes| scopes - [added_scope] }
  end

  private

  attr_reader :rewriter, :added_scope, :trigger_scopes
end
