module APIPagination
  extend ActiveSupport::Concern

  MAX_LIMIT = 1000

  def maxed_limit(requested_limit = nil, default_limit = 10)
    [requested_limit.to_i.positive? ? requested_limit.to_i : default_limit, MAX_LIMIT].min
  end
end
