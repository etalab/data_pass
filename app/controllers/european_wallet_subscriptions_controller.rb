class EuropeanWalletSubscriptionsController < ApplicationController
  include Authentication

  allow_unauthenticated_access

  rate_limit to: 10,
    within: 1.minute,
    store: Rails.application.config.x.public_rate_limit_store,
    with: -> { render_european_wallet_page(:rate_limited, status: :too_many_requests) }

  def create
    result = SubscribeToEuropeanWalletOpening.call(
      **subscription_params.to_h.symbolize_keys.slice(:email, :profile),
      honeypot: params[:website],
      registry_open: FeatureFlag.enabled?(:european_wallet_registry_open),
    )

    render_outcome(result)
  end

  private

  def render_outcome(result)
    if result.success? || result.spam
      @saved_subscriber = result.subscriber if result.success?
      render_european_wallet_page(:confirmed)
    elsif result.not_saved
      render_european_wallet_page(:not_saved, status: :unprocessable_content)
    else
      @european_wallet_subscriber = result.subscriber
      render_european_wallet_page(:invalid, status: :unprocessable_content)
    end
  end

  def render_european_wallet_page(outcome, status: :ok)
    @european_wallet_subscription_outcome = outcome
    @european_wallet_subscriber ||= EuropeanWalletSubscriber.new(subscription_params) unless outcome == :confirmed
    render 'pages/european_wallet', status:
  end

  def subscription_params
    submitted = params[:european_wallet_subscriber]
    submitted = ActionController::Parameters.new unless submitted.is_a?(ActionController::Parameters)

    submitted.permit(:email, :profile)
  end

  def layout_name
    'wide_container'
  end

  def track_impersonation_action
    return if model_to_track_for_impersonation.nil?

    super
  end

  def model_to_track_for_impersonation
    @saved_subscriber
  end
end
