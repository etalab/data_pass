# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Track impersonation actions', type: :acceptance do
  def all_subclasses(klass)
    ObjectSpace.each_object(Class).select { |c| c < klass }.reject { |c| c.name.nil? }
  end

  before do
    Rails.root.glob('app/controllers/**/**/*_controller.rb').each do |file|
      require_dependency file
    end
  end

  let(:skipped_controllers) do
    [
      DGFIP::ExportController,
      SessionsController,
    ]
  end

  def controller_has_tracked_actions?(controller)
    tracked_actions = %w[create update destroy]
    controller.instance_methods.any? { |method| tracked_actions.include?(method.to_s) }
  end

  it 'has model_to_track_for_impersonation defined for each relevant controllers' do
    all_subclasses(ApplicationController).each do |controller|
      next if skipped_controllers.include?(controller)
      # rubocop:disable Performance/CollectionLiteralInLoop
      next if %w[Admin API].any? { |namespace| controller.name.start_with?(namespace) }
      # rubocop:enable Performance/CollectionLiteralInLoop

      next unless controller_has_tracked_actions?(controller)

      expect(controller.private_method_defined?(:model_to_track_for_impersonation)).to be(true),
        "Controller #{controller.name} does not define `model_to_track_for_impersonation` method"
    end
  end
end
