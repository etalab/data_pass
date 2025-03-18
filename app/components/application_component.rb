class ApplicationComponent < ViewComponent::Base
  delegate :dom_id, :strip_tags, :t, :link_to,
    :content_tag,
    to: :helpers
end
