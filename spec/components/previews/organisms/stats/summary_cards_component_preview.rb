class Organisms::Stats::SummaryCardsComponentPreview < ApplicationPreview
  def default
    render Organisms::Stats::SummaryCardsComponent.new
  end
end
