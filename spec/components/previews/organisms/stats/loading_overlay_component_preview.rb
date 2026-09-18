class Organisms::Stats::LoadingOverlayComponentPreview < ApplicationPreview
  def default
    render Organisms::Stats::LoadingOverlayComponent.new
  end
end
