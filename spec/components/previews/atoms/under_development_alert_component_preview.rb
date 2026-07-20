class Atoms::UnderDevelopmentAlertComponentPreview < ApplicationPreview
  def default
    render Atoms::UnderDevelopmentAlertComponent.new(wip_action: 'modifier votre formulaire')
  end
end
