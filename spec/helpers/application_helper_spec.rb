require 'rails_helper'

RSpec.describe ApplicationHelper do
  it 'does not define linkify_urls' do
    expect(helper).not_to respond_to(:linkify_urls)
  end
end
