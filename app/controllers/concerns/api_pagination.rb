module ApiPagination
  extend ActiveSupport::Concern

  MAX_LIMIT = 1000

  # Limits the number of records to be returned, respecting the maximum limit
  # @param requested_limit [Integer, String, nil] the requested limit
  # @param default_limit [Integer] the default limit to use if none is provided
  # @return [Integer] the limit to use, not exceeding MAX_LIMIT
  def maxed_limit(requested_limit = nil, default_limit = 10)
    [requested_limit.to_i.positive? ? requested_limit.to_i : default_limit, MAX_LIMIT].min
  end
end
