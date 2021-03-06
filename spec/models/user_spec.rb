# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(64)       not null
#  encrypted_password     :string(64)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string
#  locked_at              :datetime
#  remember_created_at    :datetime
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  sysadmin               :boolean          default(FALSE), not null
#  name                   :string(64)       not null
#  invitation_token       :string
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invited_by_id          :integer
#  google_uid             :string
#  uuid                   :string           not null
#
# Indexes
#
#  fk__users_invited_by_id              (invited_by_id)
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_invitation_token      (invitation_token) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#
# Foreign Keys
#
#  fk_users_invited_by_id  (invited_by_id => users.id) ON DELETE => no_action ON UPDATE => no_action
#

require 'rails_helper'

RSpec.describe User do
  it 'has a gravatar_url' do
    user = described_class.new(email: 'test@example.com')
    md5 = '55502f40dc8b7c769880b10874abc9d0'

    expect(user.gravatar_url).to eq "https://secure.gravatar.com/avatar/#{md5}.png?d=mm&r=PG&s=40"
  end

  describe '.ordered' do
    it 'returns ordered by email' do
      user3 = FactoryGirl.create(:user, email: 'user3@example.com')
      user1 = FactoryGirl.create(:user, email: 'user1@example.com')
      user2 = FactoryGirl.create(:user, email: 'user2@example.com')

      expect(described_class.ordered).to eq [user1, user2, user3]
    end
  end

  it { is_expected.to strip_attribute(:name).collapse_spaces }
  it { is_expected.to strip_attribute(:email).collapse_spaces }

  describe '#valid?' do
    it 'validates database schema' do
      is_expected.to validate_presence_of(:name)
    end

    it { is_expected.to allow_value('someone@example.com').for(:email) }

    it do
      is_expected.not_to allow_value('test@')
        .for(:email).with_message('is not a valid email address')
    end

    it { is_expected.to validate_length_of(:password).is_at_least(6).is_at_most(128) }

    it 'allows strong passwords' do
      user = FactoryGirl.build(:user)
      user.password = user.password_confirmation = Faker::Internet.password(20, 30)
      expect(user).to be_valid
    end

    it 'does not allow weak passwords' do
      user = FactoryGirl.build(:user)
      user.password = user.password_confirmation = 'password'
      expect(user).not_to be_valid
    end

    it 'tells the user why their password is weak' do
      user = FactoryGirl.build(:user)
      user.password = user.password_confirmation = 'password'
      user.valid?
      expect(user.errors[:password].first).to include 'This is a top-10 common password'
    end

    it { is_expected.to validate_length_of(:name).is_at_least(3).is_at_most(64) }
  end

  describe '#save' do
    subject(:user) { FactoryGirl.build(:user) }

    it 'sets a uuid' do
      user.save!
      expect(user.uuid).to match(/\A[0-9a-f-]+\z/)
    end
  end

  describe '#admin_for_site?' do
    context 'when admin of site' do
      let(:user) { FactoryGirl.create(:user, site: site, site_admin: true) }
      let(:site) { FactoryGirl.create(:site) }

      it 'returns true' do
        expect(user.admin_for_site?(site)).to eq true
      end
    end

    context 'when admin of another site' do
      let(:user) { FactoryGirl.create(:user) }
      let(:site) { FactoryGirl.create(:site) }
      let(:another_site) { FactoryGirl.create(:site) }

      before do
        user.site_settings.create(site: site)
        user.site_settings.create(site: another_site, admin: true)
      end

      it 'returns false' do
        expect(user.admin_for_site?(site)).to eq false
      end
    end

    context 'when admin of no sites' do
      let(:user) { FactoryGirl.create(:user, site: site) }
      let(:site) { FactoryGirl.create(:site) }

      it 'returns false' do
        expect(user.admin_for_site?(site)).to eq false
      end
    end

    context 'when no sites' do
      let(:user) { FactoryGirl.create(:user) }
      let(:site) { FactoryGirl.create(:site) }

      it 'returns false' do
        expect(user.admin_for_site?(site)).to eq false
      end
    end
  end

  describe '#site_ids' do
    it 'returns all site ids for a user' do
      site = FactoryGirl.create(:site)
      user = FactoryGirl.create(:user, site: site)

      expect(user.site_ids).to eq [site.id]
    end
  end

  describe '#to_param' do
    subject(:user) { FactoryGirl.build(:user) }

    it 'uses uuid' do
      expect(user.to_param).to eq user.uuid
    end
  end
end
