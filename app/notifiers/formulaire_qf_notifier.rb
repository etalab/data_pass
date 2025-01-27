class FormulaireQFNotifier < BaseNotifier
  notifier_event_names.each do |event_name|
    define_method(event_name) do |params|
      super(params)
      webhook_notification(event_name)
    end
  end
end
