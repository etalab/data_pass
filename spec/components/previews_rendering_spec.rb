RSpec.describe 'ViewComponent previews', type: :component do
  before(:all) do
    Seeds.new.perform
  end

  after(:all) do
    Seeds.new.flushdb
  end

  around do |example|
    previous_annotation = ActionView::Base.annotate_rendered_view_with_filenames
    ActionView::Base.annotate_rendered_view_with_filenames = true
    example.run
    ActionView::Base.annotate_rendered_view_with_filenames = previous_annotation
  end

  def render_preview_template(render_args)
    vc_test_controller.prepend_view_path(Rails.root.join('spec/components/previews'))
    vc_test_controller.view_context.render(template: render_args[:template], locals: render_args[:locals])
  end

  ViewComponent::Preview.all.each do |preview|
    preview.examples.each do |example|
      it "renders #{preview.preview_name}/#{example}" do
        render_args = preview.render_args(example)

        expect {
          if render_args[:component]
            render_inline(render_args[:component], **render_args[:args], &render_args[:block])
          else
            render_preview_template(render_args)
          end
        }.not_to raise_error
      end
    end
  end
end
