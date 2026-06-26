class Molecules::SidePanelComponentPreview < ApplicationPreview
  def default
    render Molecules::SidePanelComponent.new(
      id: 'side-panel-preview',
      title: 'Modifier l’étape « Mon projet »',
      open: true
    ) do
      tag.p 'Contenu du panneau latéral.'
    end
  end
end
