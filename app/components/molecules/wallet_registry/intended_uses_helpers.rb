module Molecules::WalletRegistry::IntendedUsesHelpers
  delegate :wallet_intended_uses_t,
    :wallet_intended_use_dom_id,
    :wallet_attestation_param,
    :wallet_intended_use_command_button,
    :wallet_intended_uses_command_url,
    :authorization_request_form_wallet_rulebooks_path,
    :turbo_frame_tag,
    :wallet_intended_use_totals,
    :wallet_attestation_technical_line,
    :wallet_selected_claims,
    :wallet_preview_privacy_policy,
    :wallet_summary_period,
    to: :helpers
end
