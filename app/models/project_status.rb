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

  def cycles
    @cycles ||= habilitations.slice_when { |current, nextie| !current.next_stage&.exists? || nextie.next_stage&.exists? }.to_a.map do |stages|
      Cycle.new(stages)
    end
  end

  def multi_stage?
    definitions.map(&:stage).any?(&:exists?)
  end

  def ongoing_cycle?
    cycles.last&.ongoing?
  end

  def stage
    latest_habilitation.stage || authiorization_request.definition.stage
  end

  def ready_for_next_stage?
    authorization_request.validated? && next_stage.exists?
  end

  def next_stage
    latest_habilitation.next_stage || authorization_request.definition.next_stage_definition&.stage
  end

  def final_stage?
    next_stage.nil?
  end

  def ongoing_reopening?
    return false unless reopening

    true
  end

  class Cycle
    attr_reader :stages

    def initialize(stages)
      @stages = stages
    end

    def complete?
      stages.last.next_stage.nil? || !stages.last.next_stage.exists?
    end

    def ongoing?
      !complete?
    end
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

    def next_stage
      habilitation.definition.next_stage_definition&.stage
    end
  end

  private

  def definitions
    [authorization_request.definition] + authorization_request.authorizations.map(&:definition)
  end

  def latest_habilitation
    habilitations.last
  end
end
