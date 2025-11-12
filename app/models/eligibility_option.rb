class EligibilityOption
  include Draper::Decoratable

  attr_reader :type, :eligible, :body, :cta

  def initialize(attributes)
    @type = attributes['type']
    @eligible = attributes['eligible']
    @body = attributes['body']
    @cta = attributes['cta']
  end
end
