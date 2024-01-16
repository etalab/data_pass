class BaseNotifier < ApplicationNotifier
  %w[
    submit
    changes_requested
    validated
    refused
  ].each do |event|
    define_method(event) do |params|
      email_notification(event, params)
    end
  end

  %w[
    draft
    archived
  ].each do |event|
    # rubocop:disable Lint/EmptyBlock
    define_method(event) do |params|
    end
    # rubocop:enable Lint/EmptyBlock
  end
end
