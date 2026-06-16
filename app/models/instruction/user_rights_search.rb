class Instruction::UserRightsSearch
  SEARCH_ATTRIBUTE = :email_or_given_name_or_family_name_cont

  def initialize(scope:, params:)
    @scope = scope
    @params = params
  end

  def term
    return @term if defined?(@term)

    raw = raw_term
    @term = raw.strip.presence if raw.is_a?(String)
  end

  def engine
    @engine ||= scope.ransack(ransack_params)
  end

  def results
    engine.result.order(:email)
  end

  private

  attr_reader :scope, :params

  def raw_term
    params.dig(:search_query, SEARCH_ATTRIBUTE)
  end

  def ransack_params
    return {} if term.blank?

    { SEARCH_ATTRIBUTE => term }
  end
end
