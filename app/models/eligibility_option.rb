class EligibilityOption
  include Draper::Decoratable

  attr_reader :type, :eligible, :body, :cta, :use_case, :custom_label, :description, :request_access_params

  def initialize(attributes)
    @type = attributes['type']
    @eligible = attributes['eligible']
    @body = attributes['body']
    @cta = attributes['cta']
    @use_case = attributes['use_case']
    @custom_label = attributes['label']
    @description = attributes['description']
    @request_access_params = attributes['request_access_params'] || {}
  end
end
