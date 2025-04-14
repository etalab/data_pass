# rubocop:disable Rails/Output

# create a user with the developer role for the dgfip datapasses through the rails console

FactoryBot.create(:user, email: 'datapass@yopmail.com', roles: ['admin'], external_id: rand(1..100_000)) if User.find_by(email: 'datapass@yopmail.com').nil?
u = User.find_by(email: 'datapass@yopmail.com')
u.roles = []
u.roles += %w[api_impot_particulier:developer api_impot_particulier_sandbox:developer api_sfip:developer api_sfip_sandbox:developer api_hermes_sandbox:developer api_hermes:developer api_e_contacts_sandbox:developer api_e_contacts:developer api_opale_sandbox:developer api_opale:developer api_ocfi_sandbox:developer api_ocfi:developer api_e_pro_sandbox:developer api_e_pro:developer api_robf_sandbox:developer api_robf:developer api_cpr_pro_adelie_sandbox:developer api_cpr_pro_adelie:developer api_imprimfip_sandbox:developer api_imprimfip:developer api_satelit_sandbox:developer api_satelit:developer api_mire_sandbox:developer api_mire:developer api_ensu_documents_sandbox:developer api_ensu_documents:developer api_rial_sandbox:developer api_rial:developer api_infinoe:developer api_infinoe_sandbox:developer api_ficoba:developer api_ficoba_sandbox:developer api_r2p_sandbox:developer api_r2p:developer]
u.roles += %w[api_impot_particulier:instructor api_impot_particulier_sandbox:instructor api_sfip:instructor api_sfip_sandbox:instructor api_hermes_sandbox:instructor api_hermes:instructor api_e_contacts_sandbox:instructor api_e_contacts:instructor api_opale_sandbox:instructor api_opale:instructor api_ocfi_sandbox:instructor api_ocfi:instructor api_e_pro_sandbox:instructor api_e_pro:instructor api_robf_sandbox:instructor api_robf:instructor api_cpr_pro_adelie_sandbox:instructor api_cpr_pro_adelie:instructor api_imprimfip_sandbox:instructor api_imprimfip:instructor api_satelit_sandbox:instructor api_satelit:instructor api_mire_sandbox:instructor api_mire:instructor api_ensu_documents_sandbox:instructor api_ensu_documents:instructor api_rial_sandbox:instructor api_rial:instructor api_infinoe:instructor api_infinoe_sandbox:instructor api_ficoba:instructor api_ficoba_sandbox:instructor api_r2p_sandbox:instructor api_r2p:instructor]

u.save!
Doorkeeper::Application.create!(name: 'DGFiP', redirect_uri: 'https://www.google.com', owner: u)

da = u.oauth_applications.first
puts "User created.\nCLIENT_ID: #{da.uid}\nCLIENT_SECRET: #{da.secret}"

puts "\nRun:\npython3 lib/suivi_dtnum/main.py #{da.uid} #{da.secret}\n"

# rubocop:enable Rails/Output
