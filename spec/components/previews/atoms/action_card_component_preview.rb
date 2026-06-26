class Atoms::ActionCardComponentPreview < ApplicationPreview
  def with_detail
    render Atoms::ActionCardComponent.new(
      title: 'Modifier les étapes du formulaire',
      description: 'Ajoutez, réorganisez ou supprimez les étapes et les questions présentées au demandeur.',
      link: '#',
      detail: '5 étapes',
      icon: 'fr-icon-draft-line'
    )
  end

  def without_detail
    render Atoms::ActionCardComponent.new(
      title: 'Gérer les emails automatiques',
      description: 'Consultez le contenu et les destinataires des emails automatiques.',
      link: '#'
    )
  end
end
