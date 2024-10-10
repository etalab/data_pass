class AuthorizationRequestFormDecorator < ApplicationDecorator
  delegate_all

  def tags
    tags = []

    tags << 'default' if default
    tags << service_provider.id if service_provider
    tags << use_case if use_case

    tags
  end
end
