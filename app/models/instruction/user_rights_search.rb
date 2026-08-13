class Instruction::UserRightsSearch
  SEARCH_ATTRIBUTE = :email_or_given_name_or_family_name_cont

  PRESENCE_SCOPES = {
    'with' => :with_specific_definition_rights,
    'without' => :without_specific_definition_rights,
  }.freeze

  def initialize(scope:, params:)
    @scope = scope
    @params = params
  end

  def term
    return @term if defined?(@term)

    @term = string_param(raw_term)
  end

  def role_type
    return @role_type if defined?(@role_type)

    @role_type = string_param(filters[:role])
  end

  def droit
    return @droit if defined?(@droit)

    @droit = string_param(filters[:droit])
  end

  def results
    apply_droit(apply_role_type(engine.result)).order(:email)
  end

  def engine
    @engine ||= scope.ransack(ransack_params)
  end

  private

  attr_reader :scope, :params

  def apply_role_type(relation)
    return relation if role_type.blank?

    relation.with_role_type(role_type)
  end

  def apply_droit(relation)
    return relation if droit.blank?

    presence_scope = PRESENCE_SCOPES[droit]
    return relation.public_send(presence_scope) if presence_scope

    relation.with_specific_definition(droit)
  end

  def filters
    raw = params[:filters]
    raw.is_a?(ActionController::Parameters) ? raw : ActionController::Parameters.new
  end

  def raw_term
    params.dig(:search_query, SEARCH_ATTRIBUTE)
  end

  def string_param(value)
    value.strip.presence if value.is_a?(String)
  end

  def ransack_params
    return {} if term.blank?

    { SEARCH_ATTRIBUTE => term }
  end
end
