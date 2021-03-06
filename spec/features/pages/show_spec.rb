require 'rails_helper'

RSpec.feature 'Page show' do
  scenario 'public page' do
    Timecop.freeze(Time.zone.now - 1.month - 3.days) do
      home_page.update! updated_at: Time.zone.now
    end

    visit_200_page '/home'

    expect(page).to have_selector 'body.page-home'

    within 'article' do
      expect(page).to have_content 'Home'
      expect(body).to include home_page.html_content
      expect(body).to include home_page.custom_html
    end

    within 'footer' do
      expect(page).to have_content 'Page last updated about a month ago'
    end
  end

  scenario 'private page' do
    private_page = FactoryGirl.create(:page, :private, site: site)
    login_as site_user
    visit_200_page "/#{private_page.url}"

    expect(page).to have_selector 'h1 .fa-lock'
  end
end
