require 'rails_helper'

RSpec.describe 'GET /:id' do
  context 'private page' do
    let(:page) { FactoryGirl.create(:page, :private, site: site) }
    let(:request_path_id) { page.url }

    include_examples 'authenticated page'
  end

  context 'page from another site' do
    let(:page) { FactoryGirl.create(:page) }
    let(:request_path_id) { page.url }

    include_examples 'renders page not found'
  end
end
