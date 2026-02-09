class Molecules::DurationCardComponentPreview < ViewComponent::Preview
  def duration
    render Molecules::DurationCardComponent.new(
      title: I18n.t('stats.durations.fill_title'),
      percentile_50_target: 'percentile50TimeToSubmit',
      percentile_80_target: 'percentile80TimeToSubmit',
      type: :duration
    )
  end

  def delay
    render Molecules::DurationCardComponent.new(
      title: I18n.t('stats.durations.first_response_title'),
      percentile_50_target: 'percentile50TimeToFirstInstruction',
      percentile_80_target: 'percentile80TimeToFirstInstruction',
      type: :delay
    )
  end
end
