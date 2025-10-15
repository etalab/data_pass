class AbstractInstructionMailer < ApplicationMailer
  protected

  def instructors_or_reporters_to_notify
    @instructors_or_reporters_to_notify ||= instructors_or_reporters.reject do |user|
      !user.public_send(:"instruction_submit_notifications_for_#{model_for_instructors_or_reporters.definition.id.underscore}") &&
        user != model_for_instructors_or_reporters.applicant
    end
  end

  def instructors_or_reporters
    model_for_instructors_or_reporters.definition.instructors_or_reporters
  end

  def model_for_instructors_or_reporters
    authorization_request
  end
end
