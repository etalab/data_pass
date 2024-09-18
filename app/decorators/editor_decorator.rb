class EditorDecorator < ApplicationDecorator
  delegate_all

  def scroll_target
    if already_integrated?(scope: context[:scope])
      'editor-already-integrated-disclaimer'
    else
      'forms'
    end
  end
end
