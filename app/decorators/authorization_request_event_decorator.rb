class AuthorizationRequestEventDecorator < ApplicationDecorator
  delegate_all

  def user_full_name
    return unless user

    user.full_name
  end

  def name
    case object.name
    when 'submit'
      if initial_submit?
        'initial_submit'
      else
        'submit'
      end
    else
      object.name
    end
  end

  def text
    case name
    when 'refuse', 'request_changes'
      entity.reason
    when 'submit'
      humanized_changelog
    end
  end

  private

  def humanized_changelog
    h.content_tag(:ul) do
      object.entity.diff.map { |attribute, values|
        h.content_tag(:li, build_attribute_change(attribute, values))
      }.join.html_safe
    end
  end

  def build_attribute_change(attribute, values)
    t(
      'authorization_request_event.changelog_entry',
      attribute: object.authorization_request.class.human_attribute_name(attribute),
      old_value: values.first,
      new_value: values.last,
    )
  end

  def initial_submit?
    object.entity.diff.all? { |_attribute, values| values.first.nil? }
  end
end
