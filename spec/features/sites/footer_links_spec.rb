require 'rails_helper'

RSpec.feature 'Footer links' do
  let(:css_selector) { '.footer__site-links' }

  scenario 'site with footer links' do
    link1 = FactoryGirl.create(:footer_link, site: site)
    FactoryGirl.create(:footer_link, site: site, icon: 'facebook-official')

    visit_200_page '/home'

    within css_selector do
      expect(page).to have_link link1.name, href: link1.url
      expect(page).to have_selector '.fa-facebook-official'
    end
  end

  scenario 'site without footer links' do
    visit_200_page '/home'

    expect(page).not_to have_selector css_selector
  end
end
