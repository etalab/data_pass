class Organisms::PublicRegistry::SidebarComponent < ApplicationComponent
  def initialize(url:, origins: [], query: nil)
    @url = url
    @origins = origins
    @query = query
  end

  attr_reader :url, :origins, :query
end
