class Organisms::PublicRegistry::ResultsListComponent < ApplicationComponent
  renders_many :tiles, Molecules::PublicRegistry::AuthorizationTileComponent

  def render?
    tiles?
  end

  def call
    tag.ul(class: 'fr-grid-row fr-grid-row--gutters fr-raw-list') do
      safe_join(tiles.map { |tile| tag.li(tile, class: 'fr-col-12') })
    end
  end
end
