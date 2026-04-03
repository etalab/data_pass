Quand('cette demande est issue de la v1 et non intègre') do
  last_authorization_request.update!(
    dirty_from_v1: true,
  )
end
