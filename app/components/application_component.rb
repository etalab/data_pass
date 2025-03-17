class ApplicationComponent < ViewComponent::Base
  delegate :dom_id, :strip_tags, :t, :link_to,
           :authorization_request_authorization_path,
           :content_tag,
           to: :helpers

end
