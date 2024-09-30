class ContactDefinition
  attr_reader :type, :options

  def initialize(type, options = {})
    @type = type
    @options = options
  end

  def required_personal_email?
    options.fetch(:required_personal_email, false)
  end
end
