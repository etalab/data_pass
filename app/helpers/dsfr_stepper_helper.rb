module DSFRStepperHelper
  def dsfr_stepper(current_step:, steps:)
    content_tag(:div, class: 'fr-stepper') do
      [
        dsfr_stepper_title(current_step, steps),
        dsfr_stepper_steps(current_step, steps),
        dsfr_stepper_details(current_step, steps),
      ].join(' ').html_safe
    end
  end

  private

  def dsfr_stepper_title(current_step, steps)
    content_tag(:h2, class: 'fr-stepper__title') do
      [
        current_step,
        content_tag(:span, class: 'fr-stepper__state') do
          t('dsfr.stepper.state', step_number: stepper_step_number(current_step, steps), steps_count: steps.size)
        end,
      ].join(' ').html_safe
    end
  end

  def dsfr_stepper_steps(current_step, steps)
    content_tag(
      :div,
      '',
      class: 'fr-stepper__steps',
      data: {
        'fr-current-step': stepper_step_number(current_step, steps),
        'fr-steps': steps.size
      }
    ).html_safe
  end

  def dsfr_stepper_details(current_step, steps)
    return '' if stepper_next_step(current_step, steps).nil?

    content_tag(:p, class: 'fr-stepper__details') do
      [
        content_tag(:span, t('dsfr.stepper.next_step'), class: 'fr-text--bold'),
        stepper_next_step(current_step, steps),
      ].join(' ').html_safe
    end
  end

  def stepper_step_number(current_step, steps)
    steps.index(current_step) + 1
  end

  def stepper_next_step(current_step, steps)
    return if current_step == steps.last

    steps[stepper_step_number(current_step, steps)]
  end

  def authorization_request_step_name(authorization_request, step)
    t(
      "authorization_request_forms.#{authorization_request.model_name.element}.steps.#{step}",
      default: t("authorization_request_forms.default.steps.#{step}")
    )
  end
end
