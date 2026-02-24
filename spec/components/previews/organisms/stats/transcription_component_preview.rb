class Organisms::Stats::TranscriptionComponentPreview < ViewComponent::Preview
  def default
    render Organisms::Stats::TranscriptionComponent.new(
      id: 'preview',
      title: I18n.t('stats.chart.transcription_title'),
      description: I18n.t('stats.chart.transcription_description')
    )
  end
end
