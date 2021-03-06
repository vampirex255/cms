require 'rails_helper'

RSpec.feature 'User locking' do
  scenario 'after 5 attempts then unlocking' do
    visit_200_page '/login'

    5.times do
      fill_in 'Email', with: site_user.email
      fill_in 'Password', with: new_password
      click_button 'Login'
      expect(page).to have_content 'Invalid Email or password.'
    end

    email = last_email
    expect(email.to).to eq [site_user.email]
    expect(email.subject).to eq 'Unlock instructions'

    link = email.html_part.body.match(/href="([^"]+)/)[1]
    expect(link).to include site.host
    link.gsub!("http://#{site.host}", Capybara.app_host)

    unchecked_visit link

    expect(page).to have_content 'Your account has been unlocked'

    fill_in 'Email', with: site_user.email
    fill_in 'Password', with: site_user.password
    click_button 'Login'

    expect(page).to have_content 'Signed in successfully.'
  end

  scenario 'resending unlock email' do
    visit_200_page '/login'

    5.times do
      fill_in 'Email', with: site_user.email
      fill_in 'Password', with: new_password
      click_button 'Login'
      expect(page).to have_content 'Invalid Email or password.'
    end

    last_email

    visit_200_page '/user/unlock/new'

    expect(page).to have_content 'Unlock account'

    fill_in 'Email', with: site_user.email
    click_button 'Resend unlock instructions'

    expect(page).to have_content 'If your account exists'

    email = last_email
    expect(email.to).to eq [site_user.email]
    expect(email.subject).to eq 'Unlock instructions'
  end

  scenario 'non user' do
    visit_200_page '/user/unlock/new'

    fill_in 'Email', with: new_email
    click_button 'Resend unlock instructions'

    expect(page).to have_content 'If your account exists'
  end
end
