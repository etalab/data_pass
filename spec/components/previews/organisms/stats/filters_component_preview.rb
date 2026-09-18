class Organisms::Stats::FiltersComponentPreview < ApplicationPreview
  def default
    render Organisms::Stats::FiltersComponent.new
  end
end
