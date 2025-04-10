module AuthorizationExtensions::TechnicalTeam
  extend ActiveSupport::Concern

  included do
    add_attributes :technical_team_type,
      :technical_team_value

    before_save :clean_technical_team_value, if: -> { technical_team_types_requiring_values.exclude?(technical_team_type) }

    validates :technical_team_type,
      presence: true,
      inclusion: { in: ->(authorization_request) { authorization_request.available_technical_team_types.dup.values } },
      if: -> { need_complete_validation?(:technical_team) }

    validates :technical_team_value,
      presence: true,
      if: -> { technical_team_types_requiring_values.include?(technical_team_type) && need_complete_validation?(:technical_team) }
  end

  def technical_team_types_requiring_values
    self.class::TECHNICAL_TEAM_TYPES_REQUIRING_VALUES
  rescue NameError
    raise "Must declare a constant TECHNICAL_TEAM_TYPES_REQUIRING_VALUES in the model #{self.class}"
  end

  def available_technical_team_types
    self.class::TECHNICAL_TEAM_TYPES
  rescue NameError
    raise "Must declare a constant TECHNICAL_TEAM_TYPES in the model #{self.class}"
  end

  private

  def clean_technical_team_value
    data.delete 'technical_team_value'
  end
end
