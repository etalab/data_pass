require 'rails_helper'
require 'rake'

RSpec.describe 'form_templates rake tasks' do
  before(:all) do
    Rails.application.load_tasks if Rake::Task.tasks.none? { |t| t.name == 'form_templates:backfill_defaults' }
  end

  describe 'form_templates:backfill_defaults' do
    let(:task) { Rake::Task['form_templates:backfill_defaults'] }

    before { task.reenable }

    it 'creates a default FormTemplate for HTs missing one' do
      ht_a = create(:habilitation_type)
      ht_b = create(:habilitation_type)
      ht_a.form_templates.delete_all
      ht_b.form_templates.delete_all

      expect { task.invoke }
        .to change { FormTemplate.where(default: true).count }.by(2)

      expect(ht_a.form_templates.where(default: true).count).to eq(1)
      expect(ht_b.form_templates.where(default: true).count).to eq(1)
    end

    it 'is idempotent: a second invocation does not create duplicates' do
      ht = create(:habilitation_type)
      ht.form_templates.delete_all

      task.invoke
      task.reenable

      expect { task.invoke }.not_to(change(FormTemplate, :count))
    end

    it 'skips HTs that already have a default template' do
      create(:habilitation_type)

      expect { task.invoke }.not_to(change(FormTemplate, :count))
    end
  end
end
