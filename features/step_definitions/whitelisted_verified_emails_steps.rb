Quand("il y a l'email {string} marqué en tant que {string}") do |email, kind|
  case kind
  when 'délivrable'
    status = 'deliverable'
  when 'liste blanche'
    status = 'whitelisted'
  end

  create(:verified_email, email:, status:)
end
