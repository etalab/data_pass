namespace :form_templates do
  desc 'Backfill a default FormTemplate for HabilitationTypes that do not have one'
  task backfill_defaults: :environment do
    created = 0
    HabilitationType.find_each do |habilitation_type|
      next if habilitation_type.form_templates.exists?(default: true)

      habilitation_type.ensure_default_form_template!
      created += 1
    end

    Rails.logger.info("[form_templates:backfill_defaults] created #{created} default template(s)")
  end
end
