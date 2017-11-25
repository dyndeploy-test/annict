# frozen_string_literal: true

# == Schema Information
#
# Table name: providers
#
#  id               :integer          not null, primary key
#  user_id          :integer          not null
#  name             :string(510)      not null
#  uid              :string(510)      not null
#  token            :string(510)      not null
#  token_expires_at :integer
#  token_secret     :string(510)
#  created_at       :datetime
#  updated_at       :datetime
#
# Indexes
#
#  providers_name_uid_key  (name,uid) UNIQUE
#  providers_user_id_idx   (user_id)
#

class Provider < ApplicationRecord
  extend Enumerize

  enumerize :name, in: %i(facebook gumroad twitter)

  belongs_to :user

  scope :token_available, -> {
    where(token_expires_at: nil).
      or(where("token_expires_at > ?", Time.now.to_i))
  }

  after_save :update_supporter

  def token_expires_at=(expires_at)
    value = expires_at if name == "facebook"
    write_attribute(:token_expires_at, value)
  end

  def token_secret=(secret)
    value = secret if name == "twitter"
    write_attribute(:token_secret, value)
  end

  private

  def update_supporter
    return unless name.gumroad?

    GumroadSubscribersSyncService.execute
    subscriber = GumroadSubscriber.
      where(gumroad_user_id: uid, gumroad_ended_at: nil).
      or(GumroadSubscriber.where(gumroad_user_id: uid).after(field: :gumroad_ended_at)).first

    return if subscriber.blank?

    user.gumroad_subscriber = subscriber
    user.save
  end
end
