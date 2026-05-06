class Atoms::ColorBadgeComponentPreview < ViewComponent::Preview
  def role_manager
    render Atoms::ColorBadgeComponent.new(label: 'Manager', color: 'purple-glycine')
  end

  def role_instructor
    render Atoms::ColorBadgeComponent.new(label: 'Instructeur', color: 'pink-tuile')
  end

  def role_reporter
    render Atoms::ColorBadgeComponent.new(label: 'Observateur', color: 'yellow-tournesol')
  end

  def role_developer
    render Atoms::ColorBadgeComponent.new(label: 'Développeur', color: 'blue-ecume')
  end

  def size_md
    render Atoms::ColorBadgeComponent.new(label: 'Manager', color: 'purple-glycine', size: :md)
  end
end
