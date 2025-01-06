class NewAuthorizationRequest::Base
  attr_reader :authorization_definition

  delegate :name, to: :authorization_definition, prefix: true

  def initialize(authorization_definition:)
    @authorization_definition = authorization_definition
  end

  def already_integrated_editors
    fail NotImplementedError
  end

  def already_integrated_editors_ids
    already_integrated_editors.map(&:id)
  end

  def decorated_editors
    @decorated_editors ||= ServiceProviderDecorator.decorate_collection(sorted_editors)
  end

  def decorated_editors_ids
    decorated_editors.map(&:id)
  end

  def editors
    fail NotImplementedError
  end

  def editors_index
    @editors_index ||= decorated_editors.group_by { |editor|
      first_char = editor.name.upcase[0]
      group_non_letter_within_123_label(first_char)
    }.sort
  end

  def public_available_forms
    AuthorizationRequestFormDecorator.decorate_collection(authorization_definition.public_available_forms)
  end

  private

  def sorted_editors
    editors.uniq.sort_by { |editor| editor.name.downcase }
  end

  def group_non_letter_within_123_label(char)
    char.match?(/[A-Z]/) ? char : '123'
  end
end
