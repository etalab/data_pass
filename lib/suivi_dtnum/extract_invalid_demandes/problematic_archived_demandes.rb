problem_ids = [41064,48428,49034,49071,51506,53071,53782,57086,57862,59839,59988,60470,60471,60581,60599,63921,64142]

dgfip_authorizations_definitions = AuthorizationDefinition.all.select { |definition| definition.provider.id == 'dgfip' }
dgfip_authorizations_types = dgfip_authorizations_definitions.map { |definition| definition.authorization_request_class.to_s }


diagnostics = problem_ids.map do |problem_id|
  demande = AuthorizationRequest.find(problem_id)

  diagnostic = ""

  if dgfip_authorizations_types.include?(demande.type.to_s)
    if demande.events.where(name: 'submit').any?
      diagnostic = "PROBLEM REEL"
    else
      diagnostic = "BROUILLON JAMAIS SOUMIS"
    end
  else
    diagnostic = "PAS DE LA DGFIP"
  end

  [demande.id, demande.form_uid, demande.state, diagnostic]
end

puts diagnostics.map{|d| d.join(',')}.join("\n")
