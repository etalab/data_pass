class AuthorizationRequestFormDecorator < ApplicationDecorator
  delegate_all

  def tags
    tags = []

    tags << 'default' if default
    tags << editor.id if editor
    tags << use_case if use_case

    tags
  end
end
