class Molecules::PublicRegistry::SearchBarComponent < ApplicationComponent
  INPUT_ID = 'public-registry-search'.freeze
  HINT_ID = 'public-registry-search-hint'.freeze

  def initialize(url:, query: nil, origins: [])
    @url = url
    @query = query
    @origins = Molecules::PublicRegistry::Origin.normalize(origins)
  end

  attr_reader :url, :query, :origins

  def origins_value
    origins.join(',')
  end
end
