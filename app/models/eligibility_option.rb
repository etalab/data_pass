class EligibilityOption
  include Draper::Decoratable

  attr_reader :type, :eligible, :body, :cta, :use_case, :custom_label

  def initialize(attributes)
    @type = attributes['type']
    @eligible = attributes['eligible']
    @body = attributes['body']
    @cta = attributes['cta']
    @use_case = attributes['use_case']
    @custom_label = attributes['label']
  end
end
