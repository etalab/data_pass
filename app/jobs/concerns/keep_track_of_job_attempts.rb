module KeepTrackOfJobAttempts
  extend ActiveSupport::Concern

  included do
    attr_reader :attempts
  end

  def serialize
    super.merge('tries_count' => (@attempts || 1) + 1)
  end

  def deserialize(job_data)
    super
    @attempts = job_data['tries_count']
  end
end
