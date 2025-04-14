# create a user with the developer role for the dgfip datapasses through the rails console
u = User.find_by(email: "datapass@yopmail.com")
u.roles += %w[api_impot_particulier:developer api_impot_particulier_sandbox:developer api_sfip:developer api_sfip_sandbox:developer api_hermes_sandbox:developer api_hermes:developer api_e_contacts_sandbox:developer api_e_contacts:developer api_opale_sandbox:developer api_opale:developer api_ocfi_sandbox:developer api_ocfi:developer api_e_pro_sandbox:developer api_e_pro:developer api_robf_sandbox:developer api_robf:developer api_cpr_pro_adelie_sandbox:developer api_cpr_pro_adelie:developer api_imprimfip_sandbox:developer api_imprimfip:developer api_satelit_sandbox:developer api_satelit:developer api_mire_sandbox:developer api_mire:developer api_ensu_documents_sandbox:developer api_ensu_documents:developer api_rial_sandbox:developer api_rial:developer api_infinoe:developer api_infinoe_sandbox:developer api_ficoba:developer api_ficoba_sandbox:developer api_r2p_sandbox:developer api_r2p]
u.save!
Doorkeeper::Application.create!(name: "DGFiP", redirect_uri: "https://www.google.com", owner: u)

da = u.oauth_applications.first
puts "CLIENT_ID: #{da.uid}\nCLIENT_SECRET: #{da.secret}"