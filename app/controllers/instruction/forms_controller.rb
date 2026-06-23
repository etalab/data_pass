class Instruction::FormsController < Instruction::FormManagementController
  before_action :set_authorization_definition

  def index
    authorize [:instruction, @authorization_definition], :show?
    @forms = @authorization_definition.available_forms
    @counts_by_form = preload_counts_by_form(@forms)
  end

  private

  def set_authorization_definition
    @authorization_definition = AuthorizationDefinition.find(params.expect(:authorization_definition_id))
  end

  def preload_counts_by_form(forms)
    form_uids = forms.map(&:uid)
    raw_counts = AuthorizationRequest
      .where(type: @authorization_definition.authorization_request_class.to_s, form_uid: form_uids, state: %w[validated submitted])
      .group(:form_uid, :state)
      .count

    forms.to_h do |form|
      [form.uid, {
        validated: raw_counts[[form.uid, 'validated']] || 0,
        submitted: raw_counts[[form.uid, 'submitted']] || 0
      }]
    end
  end
end
