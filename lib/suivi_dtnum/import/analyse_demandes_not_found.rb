ids_demandes_not_found = %w[64931 65432 65439 65480 65584 65600 65617 65619]
demandes_not_found = AuthorizationRequest.where(id: ids_demandes_not_found)

demandes_not_found.group(:type, :state).count
# {["AuthorizationRequest::APIImpotParticulier", "validated"] => 1,
#  ["AuthorizationRequest::APIImpotParticulierSandbox", "changes_requested"] => 3,
#  ["AuthorizationRequest::APIImpotParticulierSandbox", "refused"] => 3,
#  ["AuthorizationRequest::APIImpotParticulierSandbox", "submitted"] => 1}

demandes_not_found.map{|d| [d.state, d.id, JSON.parse(d.raw_attributes_from_v1)['id'].to_i] }
# [["refused", 64931, 64931],
#  ["validated", 65432, 65434],
#  ["refused", 65439, 65439],
#  ["refused", 65480, 65480],
#  ["changes_requested", 65584, 65584],
#  ["changes_requested", 65600, 65600],
#  ["submitted", 65617, 65617],
#  ["changes_requested", 65619, 65619]]

puts demandes_not_found.map{|d| "https://datapass.api.gouv.fr/#{JSON.parse(d.raw_attributes_from_v1)['target_api']}/#{JSON.parse(d.raw_attributes_from_v1)['id'].to_i}" }

# https://datapass.api.gouv.fr/api_impot_particulier_sandbox/64931
# https://datapass.api.gouv.fr/api_impot_particulier_sandbox/65434
# https://datapass.api.gouv.fr/api_impot_particulier_sandbox/65439
# https://datapass.api.gouv.fr/api_impot_particulier_sandbox/65480
# https://datapass.api.gouv.fr/api_impot_particulier_sandbox/65584
# https://datapass.api.gouv.fr/api_impot_particulier_sandbox/65600
# https://datapass.api.gouv.fr/api_impot_particulier_sandbox/65617
# https://datapass.api.gouv.fr/api_impot_particulier_sandbox/65619
