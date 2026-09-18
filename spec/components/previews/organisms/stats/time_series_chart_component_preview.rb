class Organisms::Stats::TimeSeriesChartComponentPreview < ApplicationPreview
  def default
    render Organisms::Stats::TimeSeriesChartComponent.new
  end
end
