module ActiveLinks
  def active_link_attribute(kind, current_path)
    return unless active_link?(kind, current_path)

    'aria-current="page"'
  end

  def active_link?(kind, current_path)
    case kind
    when 'homepage'
      current_path == root_path
    else
      false
    end
  rescue ActionController::RoutingError
    false
  end
end
