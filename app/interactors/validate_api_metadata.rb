class ValidateAPIMetadata < ApplicationInteractor
  def call
    return unless context.api_metadata_provided
    return if context.api_metadata.nil? || metadata.valid?

    fail_with_error(:invalid_metadata, errors: metadata.errors.objects, format: :metadata)
  end

  private

  def metadata
    @metadata ||= AuthorizationRequestMetadata.new(context.api_metadata)
  end
end
