class ApplicationComponent < ViewComponent::Base
  delegate :dom_id, :strip_tags, :t, :link_to,
    :content_tag, :simple_format,
    to: :helpers
end
