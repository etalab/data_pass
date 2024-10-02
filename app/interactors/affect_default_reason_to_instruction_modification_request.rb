class AffectDefaultReasonToInstructionModificationRequest < ApplicationInteractor
  def call
    return unless authorization_definition_default_reason

    context.instructor_modification_request.reason ||= authorization_definition_default_reason
  end

  private

  def authorization_definition_default_reason
    return unless File.exist?(authorization_definition_default_reason_file_path)

    File.read(authorization_definition_default_reason_file_path)
  end

  def authorization_definition_default_reason_file_path
    Rails.root.join('config', 'instruction_default_modification_request_texts', "#{authorization_request.kind}.text")
  end

  def authorization_request
    context.instructor_modification_request.authorization_request
  end
end
