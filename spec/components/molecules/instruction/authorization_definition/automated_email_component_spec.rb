RSpec.describe Molecules::Instruction::AuthorizationDefinition::AutomatedEmailComponent, type: :component do
  before { create(:data_provider, :dgfip) }

  let(:definition) { AuthorizationDefinition.find('annuaire_des_entreprises') }

  def email(mailer, action, state)
    AuthorizationDefinition::AutomatedEmails::Email.new(mailer:, action:, state:)
  end

  it 'renders the actual subject, recipients and body with placeholder values' do
    render_inline(described_class.new(
      authorization_definition: definition, event: 'approve',
      standard_email: email('AuthorizationRequestMailer', 'approve', { reopening: false })
    ))

    expect(page).to have_css('h3', text: 'Votre habilitation numéro [numéro de la demande]')
    expect(page).to have_text('[demandeur]')
    expect(page).to have_css('pre.automated-email-body', text: '[nom du demandeur]')
  end

  it 'shows the resulting state badge of the event' do
    render_inline(described_class.new(
      authorization_definition: definition, event: 'approve',
      standard_email: email('AuthorizationRequestMailer', 'approve', { reopening: false })
    ))

    expect(page).to have_css('.fr-badge--success', text: 'Validée')
  end

  it 'renders a single reopening toggle hiding the update variant of the email' do
    render_inline(described_class.new(
      authorization_definition: definition, event: 'approve',
      standard_email: email('AuthorizationRequestMailer', 'approve', { reopening: false }),
      reopening_email: email('AuthorizationRequestMailer', 'reopening_approve', { reopening: true })
    ))

    expect(page).to have_css('[data-controller="toggle-class"][data-toggle-class-class-value="fr-hidden"]')
    expect(page).to have_css('.automated-email-reopening .fr-badge--purple-glycine', count: 1, text: 'Mise à jour')
    expect(page).to have_css('[data-toggle-class-target="toggle"]:not(.fr-hidden)', text: 'Votre habilitation')
    expect(page).to have_css('[data-toggle-class-target="toggle"].fr-hidden', text: 'Votre réouverture')
  end

  it 'keeps the status badge out of the toggled zone' do
    render_inline(described_class.new(
      authorization_definition: definition, event: 'approve',
      standard_email: email('AuthorizationRequestMailer', 'approve', { reopening: false }),
      reopening_email: email('AuthorizationRequestMailer', 'reopening_approve', { reopening: true })
    ))

    expect(page).to have_css('.fr-badge--success', count: 1, text: 'Validée')
    expect(page).to have_no_css('[data-toggle-class-target="toggle"] .fr-badge--success')
  end

  it 'does not render a toggle when there is no reopening variant' do
    render_inline(described_class.new(
      authorization_definition: definition, event: 'revoke',
      standard_email: email('AuthorizationRequestMailer', 'revoke', {})
    ))

    expect(page).to have_no_css('.fr-toggle')
  end

  it 'shows the error message in place of the preview when rendering fails' do
    render_inline(described_class.new(
      authorization_definition: definition, event: 'approve',
      standard_email: email('UnknownMailer', 'approve', { reopening: false })
    ))

    expect(page).to have_css('.fr-text-default--error', text: 'NoMethodError')
  end

  it 'keeps a heading on the card when the preview is unavailable' do
    render_inline(described_class.new(
      authorization_definition: definition, event: 'approve',
      standard_email: email('UnknownMailer', 'approve', { reopening: false })
    ))

    expect(page).to have_css('h3', text: 'Email indisponible')
  end

  it 'renders the condition and the actual recipient address of a state-based email' do
    render_inline(described_class.new(
      authorization_definition: AuthorizationDefinition.find('api_particulier'), event: 'approve',
      standard_email: email('FranceConnectMailer', 'new_scopes', { with_france_connect: true })
    ))

    expect(page).to have_text('Si la demande utilise FranceConnect en modalité d\'accès')
    expect(page).to have_text('support.partenaires@franceconnect.gouv.fr')
  end
end
