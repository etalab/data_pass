class DemandStatus
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

    delegate :definition, to: :habilitation, private: true

    delegate :stage, to: :definition

    def next_stage
      definition.next_stage_definition&.stage
    end
  end

  attr_accessor :authorization_request

  def initialize(authorization_request)
    @authorization_request = authorization_request
  end

  delegate :reopening, to: :authorization_request
  delegate :definition, to: :authorization_request, private: true

  def completed_cycles
    cycles.count(&:complete?)
  end

  def incomplete_cycle?
    cycles.last&.ongoing?
  end

  def multi_stage?
    return true if definition&.stage&.exists?

    authorization_request.authorizations.map { |authorization| authorization.definition.stage }.any?(&:exists?)
  end

  def stage
    latest_habilitation&.stage || definition.stage
  end

  def ready_for_next_stage?
    authorization_request.validated? && next_stage&.exists?
  end

  def next_stage_in_progress?
    authorization_request.submitted? && next_stage&.exists?
  end

  def next_stage
    latest_habilitation&.next_stage || definition.next_stage_definition&.stage
  end

  def final_stage?
    next_stage.nil? || !next_stage.exists?
  end

  def ongoing_reopening?
    return false unless reopening

    true
  end

  private

  def cycles
    @cycles ||= habilitations.slice_when { |current, nextie| !current.next_stage&.exists? || nextie.next_stage&.exists? }.to_a.map do |stages|
      Cycle.new(stages)
    end
  end

  def habilitations
    @habilitations ||= authorization_request.authorizations.map do |habilitation|
      HabilitationStatus.new(habilitation)
    end
  end

  def latest_habilitation
    habilitations.last
  end
end
