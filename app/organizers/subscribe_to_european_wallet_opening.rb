class SubscribeToEuropeanWalletOpening < ApplicationOrganizer
  around do |organizer|
    organizer.call
  rescue ActiveRecord::ActiveRecordError => e
    Sentry.capture_exception(e)
    context.fail!(not_saved: true)
  end

  organize RejectHoneypotSubmission,
    BuildEuropeanWalletSubscriber,
    SaveEuropeanWalletSubscriber
end
