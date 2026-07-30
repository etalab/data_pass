RSpec.describe Organisms::Instruction::AuthorizationDefinition::AutomatedEmailsComponent, type: :component do
  before { create(:data_provider, :dgfip) }

  def render_for(definition_id)
    render_inline(described_class.new(authorization_definition: AuthorizationDefinition.find(definition_id)))
  end

  it 'groups emails by event' do
    render_for('annuaire_des_entreprises')

    expect(page).to have_css('h2', text: 'Soumission de la demande')
    expect(page).to have_css('h2', text: 'Validation de la demande')
  end

  it 'shows the resulting state badge under each event' do
    render_for('annuaire_des_entreprises')

    expect(page).to have_css('.fr-badge--info', text: "En cours d'instruction")
    expect(page).to have_css('.fr-badge--success', text: 'Validée')
    expect(page).to have_css('.fr-badge--warning', text: 'A modifier')
    expect(page).to have_css('.fr-badge--error', text: 'Refusée')
    expect(page).to have_css('.fr-badge--error', text: 'Révoquée')
  end

  it 'renders each email body as code with placeholder values' do
    render_for('annuaire_des_entreprises')

    expect(page).to have_css('pre.automated-email-body', minimum: 2)
    expect(page).to have_text('[nom du demandeur]')
  end

  it 'pairs reopening variants under a « Mise à jour » toggle rather than in separate cards' do
    render_for('annuaire_des_entreprises')

    expect(page).to have_css('.automated-email-reopening .fr-badge--purple-glycine', text: 'Mise à jour')
  end

  it 'shows the actual DGFiP recipient addresses' do
    render_for('api_ficoba')

    expect(page).to have_text('test1@dgfip.finances.gouv.fr')
  end

  it 'shows conditional emails with their explanation' do
    render_for('api_particulier')

    expect(page).to have_text('Si la demande utilise FranceConnect en modalité d\'accès')
    expect(page).to have_text('Si une habilitation FranceConnect est générée automatiquement')
  end

  it 'renders the HubEE administrateur métier email with its placeholder recipient' do
    render_for('hubee_cert_dc')

    expect(page).to have_text('[administrateur métier]')
    expect(page).to have_css('pre.automated-email-body', text: 'administrateur local HubEE')
  end
end
