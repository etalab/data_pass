class EligibilityOption
  include Draper::Decoratable

  attr_reader :type, :eligible, :body, :cta, :use_case

  def initialize(attributes)
    @type = attributes['type']
    @eligible = attributes['eligible']
    @body = attributes['body']
    @cta = attributes['cta']
    @use_case = attributes['use_case']
  end
end
