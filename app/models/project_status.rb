class ProjectStatus
  attr_accessor :authorization_request

  alias project authorization_request

  def initialize(authorization_request)
    @authorization_request = authorization_request
  end

  delegate :id, :state, :reopening, to: :authorization_request
  delegate :definition, to: :authorization_request, private: true

  def habilitations
    @habilitations ||= authorization_request.authorizations.map do |habilitation|
      HabilitationStatus.new(habilitation)
    end
  end

  def stage
    authorization_request.definition.stage
  end

  def next_stage
    authorization_request.definition.next_stage_definition&.stage
  end

  def final_stage?
    next_stage.nil?
  end

  def ongoing_reopening?
    return false unless reopening

    return false if final_stage?

    true
  end

  def finished_cycle?
    debugger
    return false if reopening && !final_stage?
    return true if final_stage? && !reopening

    false
  end

  class HabilitationStatus
    attr_accessor :habilitation

    def initialize(habilitation)
      @habilitation = habilitation
    end

    delegate :id, :created_at, to: :habilitation
    delegate :definition, to: :habilitation, private: true

    def stage
      habilitation.definition.stage
    end
  end
end
