class Molecules::StatCardComponentPreview < ViewComponent::Preview
  def default
    render Molecules::StatCardComponent.new(
      title: I18n.t('stats.summary.validated'),
      target: 'validationsCount',
      style: {
        card_classes: 'fr-background-contrast--green-emeraude',
        value_classes: 'fr-text-default--success',
        col_classes: 'fr-col-12 fr-col-md-6 fr-col-lg-4'
      }
    )
  end

  def with_subtitle
    render Molecules::StatCardComponent.new(
      title: I18n.t('stats.summary.submitted'),
      target: 'totalRequestsCount',
      subtitle_target: 'reopeningsCount',
      style: {
        card_classes: 'fr-background-contrast--blue-france',
        value_classes: 'fr-text-action-high--blue-france',
        col_classes: 'fr-col-12 fr-col-md-6 fr-col-lg-4'
      }
    )
  end
end
