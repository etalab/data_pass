class ValidateAPIMetadata < ApplicationInteractor
  def call
    return if metadata_left_unchanged? || metadata.valid?

    fail_with_error(:invalid_metadata, errors: metadata.errors.objects, format: :metadata)
  end

  private

  def metadata_left_unchanged?
    context.api_metadata.nil?
  end

  def metadata
    @metadata ||= AuthorizationRequestMetadata::Namespace.new(context.api_metadata)
  end
end
