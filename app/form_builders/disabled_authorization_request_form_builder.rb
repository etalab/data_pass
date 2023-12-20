class DisabledAuthorizationRequestFormBuilder < AuthorizationRequestFormBuilder
  def readonly?
    true
  end
end
