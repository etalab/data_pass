class Instruction::AuthorizationDefinitionsController < Instruction::FormManagementController
  def index
    authorize %i[instruction authorization_definition], :index?
    @authorization_definitions = accessible_definitions
    @counts_by_definition = preload_counts(@authorization_definitions)
  end

  private

  def accessible_definitions
    AuthorizationDefinition.all
      .select { |d| current_user.reporter?(d.id) }
      .sort_by(&:name)
  end

  def preload_counts(definitions)
    types = definitions.map { |d| d.authorization_request_class.to_s }
    raw_counts = AuthorizationRequest
      .where(type: types, state: %w[validated submitted])
      .group(:type, :state)
      .count

    definitions.to_h do |d|
      type = d.authorization_request_class.to_s
      [d.id, {
        validated: raw_counts[[type, 'validated']] || 0,
        submitted: raw_counts[[type, 'submitted']] || 0
      }]
    end
  end
end
