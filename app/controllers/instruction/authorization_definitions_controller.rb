class Instruction::AuthorizationDefinitionsController < Instruction::FormManagementController
  before_action :set_authorization_definition, only: %i[show edit]

  def index
    authorize %i[instruction authorization_definition], :index?
    @authorization_definitions = accessible_definitions
    @counts_by_definition = preload_counts(@authorization_definitions)
  end

  def show
    authorize [:instruction, @authorization_definition], :show?
    @counts = preload_counts([@authorization_definition])[@authorization_definition.id]
  end

  def edit
    authorize [:instruction, @authorization_definition], :show?

    @default_form = @authorization_definition.default_form
    @static_block_names = @default_form.static_blocks.to_set { |b| b[:name].to_s }
    @authorization_request = build_preview_request(@default_form)
    @preview_organization = preview_organization
  end

  private

  def set_authorization_definition
    @authorization_definition = AuthorizationDefinition.find(params.expect(:id))
  end

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
